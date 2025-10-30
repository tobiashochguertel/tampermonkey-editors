/* global require, __dirname, module */

const CopyPlugin = require('copy-webpack-plugin');
const WrapperPlugin = require('wrapper-webpack-plugin');

const path = require('path');
const webpack = require('webpack');
const TerserPlugin = require('terser-webpack-plugin');
const process = require('process');
const { getWebpackDefineVariables } = require('./build_sys/helpers');
const LicenseWebpackPlugin = require('license-webpack-plugin').LicenseWebpackPlugin;

const getConfigs = () => {
    const rnd = process.env['rnd'] ? process.env['rnd'] : Math.random().toString(36).substr(2, 10);
    const minimize = ![ '1', 'true' ].includes(process.env['nominimize']);
    const sourceMapComment = [ '1', 'true' ].includes(process.env['source-map-comment']);
    const t = process.env.TARGET;
    const [ target, manifest ] = t.split('+');
    const target_valid = {
        chrome: true,
        firefox: true
    }[target];

    if (!target_valid) throw new Error('TARGET env variable is missing or invalid!');

    const config = {
        plugins: [
            new webpack.SourceMapDevToolPlugin(Object.assign({
                filename: 'sourcemaps/[name].js.map',
                // publicPath: 'file://' + path.resolve(path.join(__dirname, 'out/sourcemaps')) + '/',
                publicPath: 'http://localhost:8000/',
                fileContext: path.join(__dirname, 'out/build')
            }, sourceMapComment ? {} : { append: false } )),
            new LicenseWebpackPlugin({
                perChunkOutput: false,
                additionalChunkModules: {
                    page: [
                      {
                        name: 'file-system-access',
                        directory: path.join(__dirname, 'vendor', 'file-system-access')
                      }
                    ]
                },
                outputFilename: 'rel/3rdpartylicenses.txt',
                renderLicenses: modules => {
                    return modules
                        .reduce((acc, module) => {
                            const data = module.packageJson
                            return [
                                acc,
                                `Package: ${data.name} (${data.version})`,
                                `Web:     ${data.homepage ?? ''}`,
                                `License: ${module.licenseId ?? ''}`,
                                `${module.licenseText ?? ''}`,
                                '===================='
                            ].join('\n')
                        }, '')
                        .trim()
                },
            }),
        ],
        optimization: {
            usedExports: true,
            minimize,
            minimizer: [
                new TerserPlugin({
                    include: /^(\/)?rel\/.*\.js/,
                    sourceMap: true,
                    extractComments: false,
                    terserOptions: {
                        parallel: true,
                        ecma: 2020,
                        parse: {},
                        compress: {
                            passes: 3,
                            dead_code: true,
                            unsafe_proto: true,
                            inline: true,
                            keep_fargs: false,
                            hoist_funs: true,
                            conditionals: true,
                            evaluate: true,
                            booleans: true,
                            loops: true,
                            unused: true,
                            if_return: true,
                            join_vars: true,
                            collapse_vars: true,
                            reduce_vars: true,
                            drop_console: false,
                            drop_debugger: true,
                            pure_funcs: []
                        },
                        toplevel: true,
                        mangle: true, // Note `mangle.properties` is `false` by default.
                        module: false, // keep 'use strict' statements
                        nameCache: null,
                        ie8: false,
                        keep_classnames: undefined,
                        keep_fnames: false,
                        safari10: false,
                        booleans_as_integers: true,
                        output: {
                            max_line_len: 500,
                            comments: false
                        }
                    }
                })
            ]
        },
        module: {
            rules: [
                {
                    test: /\.tsx?$/,
                    use: 'ts-loader',
                    exclude: /node_modules/,
                }
            ]
        },
        resolve: {
            extensions: [".tsx", ".ts", ".js"]
        },
        mode: 'production',
        performance: {
            maxAssetSize: 2000000,
            maxEntrypointSize: 2000000
        },
        output: {
            devtoolModuleFilenameTemplate: 'http://localhost:8000/[resource-path]?[loaders]',
            filename: 'rel/[name].js',
            path: path.resolve(__dirname, 'out')
        }
    };

    const content = (c => {
        const plugins = c.plugins = [].concat(c.plugins || []);
        plugins.push(
            new webpack.DefinePlugin(getWebpackDefineVariables(target, manifest, false, rnd)),
            new WrapperPlugin({
                test: /content\.js$/,
                header: '(() => {',
                footer: '})()',
                afterOptimizations: true
            })
        );

        c.entry = {
            'content': './src/tab/content/index.ts'
        }

        return c;
    })(Object.assign({}, config));

    const page = (c => {
        const plugins = c.plugins = [].concat(c.plugins || []);
        plugins.push(
            new webpack.DefinePlugin(getWebpackDefineVariables(target, manifest, false, rnd)),
            target == 'firefox'
                ? new WrapperPlugin({
                    test: /page\.js$/,
                    header: 'this.pagejs = () => {',
                    footer: '}',
                    afterOptimizations: true
                })
                : new WrapperPlugin({
                    test: /page\.js$/,
                    header: '(() => {',
                    footer: '})()',
                    afterOptimizations: true
                })
        );

        c.entry = {
            'page': './src/tab/page/index.ts'
        }

        const resolve = c.resolve = Object.assign({}, c.resolve || {});

        resolve.alias = {
            [path.resolve(__dirname, './src/background')]: false,
            [path.resolve(__dirname, './src/polyfills')]: false,
        };

        return c;
    })(Object.assign({}, config));

    const background = (c => {
        const plugins = c.plugins = [].concat(c.plugins || []);
        plugins.push(
            new webpack.DefinePlugin(getWebpackDefineVariables(target, manifest, true, rnd)),
            new CopyPlugin({
                patterns: [
                    {
                        from: './images/*',
                        to: 'rel'
                    },
                    {
                        from: './i18n',
                        to: 'rel/_locales'
                    },
                    {
                        from: './LICENSE',
                        to: 'rel/'
                    },
                    {
                        from: './src/options/options.html',
                        to: 'rel/options.html'
                    },
                    {
                        from: './src/options/options.js',
                        to: 'rel/options.js'
                    }
                ]
            })
        );

        c.entry = {
            'background': './src/background/index.ts'
        };

        return c;
    })(Object.assign({}, config));

    return {
        config,
        content,
        page,
        background
    };
};

module.exports = getConfigs;