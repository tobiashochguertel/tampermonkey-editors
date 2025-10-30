#!/bin/bash
# Validation script to verify built extensions are correct
# Checks for Firefox code in Chrome builds and vice versa

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo ""
echo "🔍 Tampermonkey Editors - Build Validation"
echo "=========================================="
echo ""

# Check if release directories exist
if [ ! -d "release/tampermonkey_editors_999.chrome_mv3" ]; then
    echo -e "${RED}❌ Chrome build directory not found${NC}"
    echo "   Run ./scripts/quick-build.sh first"
    exit 1
fi

if [ ! -d "release/tampermonkey_editors_999.firefox_mv3" ]; then
    echo -e "${RED}❌ Firefox build directory not found${NC}"
    echo "   Run ./scripts/quick-build.sh first"
    exit 1
fi

echo "📁 Checking build directories..."
echo ""

# Function to check for forbidden patterns
check_file() {
    local file=$1
    local browser=$2
    local forbidden_patterns=()
    local required_patterns=()
    
    if [ "$browser" = "chrome" ]; then
        # Chrome-specific checks
        forbidden_patterns=(
            "browser\.scripting\.registerContentScripts"
            "browser\.runtime"
            "browser\.tabs"
            "createElement.*script"
            "\.textContent.*=.*\`"
            "document\.documentElement\.appendChild"
            "IS_FIREFOX.*true"
        )
        required_patterns=(
            "webNavigation"
            "scripting"
        )
    else
        # Firefox-specific checks
        forbidden_patterns=(
            "webNavigation\.onCommitted"
            "world.*MAIN"
        )
        required_patterns=(
            "registerContentScripts"
        )
    fi
    
    local found_forbidden=0
    local missing_required=0
    
    # Check for forbidden patterns
    for pattern in "${forbidden_patterns[@]}"; do
        if grep -q "$pattern" "$file" 2>/dev/null; then
            echo -e "${RED}  ❌ Found forbidden pattern in $browser: $pattern${NC}"
            ((ERRORS++))
            found_forbidden=1
        fi
    done
    
    # Check for required patterns (only in background.js)
    if [[ "$file" == *"background.js" ]]; then
        for pattern in "${required_patterns[@]}"; do
            if ! grep -q "$pattern" "$file" 2>/dev/null; then
                echo -e "${YELLOW}  ⚠️  Missing expected pattern in $browser: $pattern${NC}"
                ((WARNINGS++))
                missing_required=1
            fi
        done
    fi
    
    if [ $found_forbidden -eq 0 ] && [ $missing_required -eq 0 ]; then
        return 0
    fi
    return 1
}

# Check Chrome build
echo "🔍 Validating Chrome build..."
CHROME_OK=1

# Check content.js for CSP violations
if [ -f "release/tampermonkey_editors_999.chrome_mv3/content.js" ]; then
    echo "  📄 Checking content.js..."
    
    # Check file size (should be small, ~1.4KB)
    SIZE=$(stat -f%z "release/tampermonkey_editors_999.chrome_mv3/content.js" 2>/dev/null || stat -c%s "release/tampermonkey_editors_999.chrome_mv3/content.js" 2>/dev/null)
    if [ "$SIZE" -gt 2000 ]; then
        echo -e "${RED}  ❌ content.js too large: ${SIZE} bytes (expected ~1400)${NC}"
        echo -e "${YELLOW}     This suggests Firefox code wasn't eliminated${NC}"
        ((ERRORS++))
        CHROME_OK=0
    fi
    
    # Check for CSP-violating code
    if grep -q "createElement" "release/tampermonkey_editors_999.chrome_mv3/content.js"; then
        echo -e "${RED}  ❌ Found createElement in Chrome content.js (CSP violation!)${NC}"
        ((ERRORS++))
        CHROME_OK=0
    fi
    
    if grep -q "textContent" "release/tampermonkey_editors_999.chrome_mv3/content.js"; then
        echo -e "${RED}  ❌ Found textContent in Chrome content.js (CSP violation!)${NC}"
        ((ERRORS++))
        CHROME_OK=0
    fi
    
    if grep -q "pagejs" "release/tampermonkey_editors_999.chrome_mv3/content.js"; then
        echo -e "${RED}  ❌ Found pagejs in Chrome content.js (Firefox-specific!)${NC}"
        ((ERRORS++))
        CHROME_OK=0
    fi
    
    if [ $CHROME_OK -eq 1 ]; then
        echo -e "${GREEN}  ✅ content.js is clean (${SIZE} bytes)${NC}"
    fi
fi

# Check background.js
if [ -f "release/tampermonkey_editors_999.chrome_mv3/background.js" ]; then
    echo "  📄 Checking background.js..."
    check_file "release/tampermonkey_editors_999.chrome_mv3/background.js" "chrome" || CHROME_OK=0
    
    if [ $CHROME_OK -eq 1 ]; then
        echo -e "${GREEN}  ✅ background.js is correct${NC}"
    fi
fi

# Check manifest.json
if [ -f "release/tampermonkey_editors_999.chrome_mv3/manifest.json" ]; then
    echo "  📄 Checking manifest.json..."
    
    if ! grep -q '"manifest_version": 3' "release/tampermonkey_editors_999.chrome_mv3/manifest.json"; then
        echo -e "${RED}  ❌ Not a Manifest V3${NC}"
        ((ERRORS++))
        CHROME_OK=0
    fi
    
    if ! grep -q '"service_worker"' "release/tampermonkey_editors_999.chrome_mv3/manifest.json"; then
        echo -e "${RED}  ❌ Missing service_worker in background${NC}"
        ((ERRORS++))
        CHROME_OK=0
    fi
    
    if grep -q '"scripts"' "release/tampermonkey_editors_999.chrome_mv3/manifest.json"; then
        echo -e "${RED}  ❌ Found 'scripts' array (Firefox-specific!)${NC}"
        ((ERRORS++))
        CHROME_OK=0
    fi
    
    if [ $CHROME_OK -eq 1 ]; then
        echo -e "${GREEN}  ✅ manifest.json is correct${NC}"
    fi
fi

echo ""
echo "🔍 Validating Firefox build..."
FIREFOX_OK=1

# Check background.js
if [ -f "release/tampermonkey_editors_999.firefox_mv3/background.js" ]; then
    echo "  📄 Checking background.js..."
    check_file "release/tampermonkey_editors_999.firefox_mv3/background.js" "firefox" || FIREFOX_OK=0
    
    if [ $FIREFOX_OK -eq 1 ]; then
        echo -e "${GREEN}  ✅ background.js is correct${NC}"
    fi
fi

# Check manifest.json
if [ -f "release/tampermonkey_editors_999.firefox_mv3/manifest.json" ]; then
    echo "  📄 Checking manifest.json..."
    
    if ! grep -q '"manifest_version": 3' "release/tampermonkey_editors_999.firefox_mv3/manifest.json"; then
        echo -e "${RED}  ❌ Not a Manifest V3${NC}"
        ((ERRORS++))
        FIREFOX_OK=0
    fi
    
    if [ $FIREFOX_OK -eq 1 ]; then
        echo -e "${GREEN}  ✅ manifest.json is correct${NC}"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Validation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $CHROME_OK -eq 1 ]; then
    echo -e "${GREEN}✅ Chrome build: VALID${NC}"
else
    echo -e "${RED}❌ Chrome build: INVALID${NC}"
fi

if [ $FIREFOX_OK -eq 1 ]; then
    echo -e "${GREEN}✅ Firefox build: VALID${NC}"
else
    echo -e "${RED}❌ Firefox build: INVALID${NC}"
fi

echo ""
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ Validation FAILED${NC}"
    echo ""
    echo "💡 To fix:"
    echo "   1. Run: ./scripts/quick-build.sh"
    echo "   2. Run: ./scripts/validate-build.sh"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Validation passed with warnings${NC}"
    exit 0
else
    echo -e "${GREEN}✅ All checks passed!${NC}"
    echo ""
    echo "🎉 Extensions are ready to load:"
    echo "   Chrome:  release/tampermonkey_editors_999.chrome_mv3/"
    echo "   Firefox: release/tampermonkey_editors_999.firefox_mv3/"
    exit 0
fi
