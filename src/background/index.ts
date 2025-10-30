/// <reference no-default-lib="true"/>
/// <reference lib="dom" />
/// <reference lib="webworker" />
/// <reference types="chrome" />
/// <reference types="firefox-webext-browser" />
/// <reference lib="es2017" />

import '../../src/polyfills';
import { logger as console } from '../shared/logger';
import { IS_EVENTPAGE, IS_FIREFOX, IS_MV3 } from '../env';
import Config from './config';
import { findTm } from './find_tm';
import Storage from './storage';
import { hasHostPermission, requestHostPermission } from './host_permission';

const WEB_EDITOR_URL = 'https://vscode.dev/?connectTo=tampermonkey';
const DESKTOP_EDITOR_URL = 'vscode://';
const { runtime, action, tabs, webNavigation, scripting } = chrome;

const getMainUrl = (): string => {
    return Config.values.editorType === 'desktop' ? DESKTOP_EDITOR_URL : WEB_EDITOR_URL;
};

const isWebEditor = (): boolean => {
    return Config.values.editorType === 'web';
};

const setForbidden = async (forbidden: boolean) => {
    /* eslint-disable @typescript-eslint/naming-convention */
    if (forbidden) {
        action.setIcon({
            path: {
                16: 'images/icon_forbidden.png',
                24: 'images/icon24_forbidden.png',
                32: 'images/icon32_forbidden.png',
                48: 'images/icon48_forbidden.png',
                128: 'images/icon128_forbidden.png',
            },
        });
        action.setTitle({ title: 'Tampermonkey Editors - has no access to vscode.dev' });
    } else {
        action.setIcon({
            path: {
                16: 'images/icon.png',
                24: 'images/icon24.png',
                32: 'images/icon32.png',
                48: 'images/icon48.png',
                128: 'images/icon128.png',
            },
        });
        action.setTitle({ title: 'Tampermonkey Editors' });
    }
    /* eslint-enable @typescript-eslint/naming-convention */
};

const initWebNavigation = () => {
    webNavigation.onCommitted.addListener(async details => {
        const { url, tabId } = details;
        if (url.startsWith(WEB_EDITOR_URL)) {
            scripting.executeScript({
                files: [
                    'content.js'
                ],
                target: {
                    tabId,
                    frameIds: [ 0 ]
                },
                ...{ injectImmediately: true } as any,
                world: 'ISOLATED'
            });
            scripting.executeScript({
                files: [
                    'page.js'
                ],
                target: {
                    tabId,
                    frameIds: [ 0 ]
                },
                ...{ injectImmediately: true } as any,
                world: IS_FIREFOX ? 'ISOLATED' : 'MAIN'
            });
        }
    });
};

const initRegisteredContentScripts = async () => {
    const scripts = [
        {
            id: 'content',
            matches: [ WEB_EDITOR_URL + '*' ],
            js: [ 'content.js' ],
            runAt: 'document_start' as const,
        },
        {
            id: 'js',
            matches: [ WEB_EDITOR_URL + '*' ],
            js: [ 'page.js' ],
            runAt: 'document_start' as const,
        }
    ];
    const reg = await chrome.scripting.getRegisteredContentScripts();
    if (reg.length) {
        await chrome.scripting.unregisterContentScripts({
            ids: reg.map(s => s.id)
        });
    }
    await chrome.scripting.registerContentScripts(scripts);
};

const init = async () => {
    if (IS_FIREFOX) {
        initRegisteredContentScripts();
    } else if (IS_MV3) {
        initWebNavigation();
    }

    const handleMessage = async (request: any, sendResponse: (response?: any) => void): Promise<void> => {
        if (lock) {
            await lock;
            return handleMessage(request, sendResponse);
        } else {
            let resolve: () => void = () => null;

            lock = new Promise<void>(r => resolve = r);
            lock.then(() => lock = undefined);

            const r = await findTm([ WEB_EDITOR_URL ]);

            if (!r.length) {
                sendResponse({ error: 'no extension to talk to' });
                resolve();
                return;
            }

            const [ { id, port } ] = r;
            console.log(`Found extension ${id}`);

            const h = (response: any) => {
                sendResponse(response);
                port.onMessage.removeListener(h);
                resolve();
            };

            port.onMessage.addListener(h);
            port.postMessage({ method: request.method, ...request.args });
            await lock;
            lock = undefined;
        }
    };

    runtime.onMessage.addListener((request, _sender, sendResponse) => {
        handleMessage(request, sendResponse);
        return true;
    });

    let hhp: boolean | undefined;
    action.onClicked.addListener(async (_details) => {
        void(runtime.lastError);
        const mainUrl = getMainUrl();
        const isWeb = isWebEditor();
        
        if (isWeb && !hhp) {
            const granted = await requestHostPermission();
            if (granted) {
                hhp = granted;
                setForbidden(!hhp);
            } else {
                return;
            }
        }

        if (isWeb) {
            tabs.query({ url: mainUrl + '*' }, info => {
                if (info && info.length && info[0].id) {
                    tabs.update(info[0].id, { active: true }, () => runtime.lastError);
                } else {
                    tabs.create({ url: mainUrl, active: true }, () => runtime.lastError);
                }
            });
        } else {
            // For desktop editor, just open the protocol handler
            tabs.create({ url: mainUrl, active: true }, () => runtime.lastError);
        }

    });

    // eslint-disable-next-line no-async-promise-executor
    let lock: Promise<any> | undefined = (async () => {
        await Storage.init();
        await Config.init();
        console.set(Config.values.logLevel);
    })();

    (async () => {
        hhp = await hasHostPermission(WEB_EDITOR_URL);
        setForbidden(!hhp);
    })();

    await lock;
    lock = undefined;

    console.log('Tampermonkey Editors initialization done');
};

if (IS_EVENTPAGE) {
    init();
} else if (IS_MV3 ) {
    (async (self: ServiceWorkerGlobalScope) =>{
        self.oninstall = () => self.skipWaiting();
        init();
    })(self as unknown as ServiceWorkerGlobalScope);
} else {
    throw new Error('This should not happen');
}


