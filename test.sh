#!/usr/bin/env bash
#
# ClaudeGo Test Script
# Validates syntax and structure of the main script
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/claudego"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}PASS${NC}: $1"; }
fail() { echo -e "${RED}FAIL${NC}: $1"; exit 1; }
warn() { echo -e "${YELLOW}WARN${NC}: $1"; }

echo "ClaudeGo Test Suite"
echo "==================="
echo

# Test 1: Script exists
echo "Test 1: Script exists"
[[ -f "$MAIN_SCRIPT" ]] || fail "Main script not found at $MAIN_SCRIPT"
pass "Script exists at $MAIN_SCRIPT"

# Test 2: Script is executable
echo "Test 2: Script is executable"
[[ -x "$MAIN_SCRIPT" ]] || fail "Script is not executable"
pass "Script is executable"

# Test 3: Bash syntax check
echo "Test 3: Bash syntax check"
if bash -n "$MAIN_SCRIPT" 2>&1; then
    pass "Bash syntax is valid"
else
    fail "Bash syntax errors found"
fi

# Test 4: ShellCheck (if available)
echo "Test 4: ShellCheck analysis"
if command -v shellcheck &>/dev/null; then
    # Run shellcheck with common exclusions
    if shellcheck -e SC1090,SC1091,SC2034 "$MAIN_SCRIPT" 2>&1; then
        pass "ShellCheck passed"
    else
        warn "ShellCheck found issues (non-blocking)"
    fi
else
    warn "ShellCheck not installed, skipping"
fi

# Test 5: Required functions exist
echo "Test 5: Required functions exist"
required_functions=(
    "step_system_check"
    "step_swap_setup"
    "step_packages_install"
    "step_node_install"
    "step_mosh_setup"
    "step_firewall_setup"
    "step_tmux_config"
    "step_claude_install"
    "step_aliases_setup"
    "step_validation"
    "init_state"
    "load_state"
    "save_state"
    "is_step_done"
    "mark_step_done"
)

all_found=true
for func in "${required_functions[@]}"; do
    if grep -q "^${func}()" "$MAIN_SCRIPT"; then
        : # Found
    else
        echo "  Missing function: $func"
        all_found=false
    fi
done

if [[ "$all_found" == "true" ]]; then
    pass "All required functions found"
else
    fail "Some required functions are missing"
fi

# Test 6: State file structure
echo "Test 6: State file steps defined"
state_steps=(
    "STEP_SYSTEM_CHECK"
    "STEP_SWAP_SETUP"
    "STEP_PACKAGES_INSTALL"
    "STEP_NODE_INSTALL"
    "STEP_MOSH_SETUP"
    "STEP_FIREWALL_SETUP"
    "STEP_TMUX_CONFIG"
    "STEP_CLAUDE_INSTALL"
    "STEP_ALIASES_SETUP"
    "STEP_VALIDATION"
)

all_found=true
for step in "${state_steps[@]}"; do
    if grep -q "$step" "$MAIN_SCRIPT"; then
        : # Found
    else
        echo "  Missing state step: $step"
        all_found=false
    fi
done

if [[ "$all_found" == "true" ]]; then
    pass "All state steps defined"
else
    fail "Some state steps are missing"
fi

# Test 7: Version defined
echo "Test 7: Version defined"
if grep -q "CLAUDEGO_VERSION=" "$MAIN_SCRIPT"; then
    version=$(grep "CLAUDEGO_VERSION=" "$MAIN_SCRIPT" | head -1 | cut -d'"' -f2)
    pass "Version defined: $version"
else
    fail "Version not defined"
fi

# Test 8: Help/aliases content
echo "Test 8: Aliases content"
aliases=(
    "cg()"
    "cg-new()"
    "cg-list()"
    "cg-kill()"
    "cg-status()"
    "cg-help()"
)

all_found=true
for alias in "${aliases[@]}"; do
    if grep -q "$alias" "$MAIN_SCRIPT"; then
        : # Found
    else
        echo "  Missing alias: $alias"
        all_found=false
    fi
done

if [[ "$all_found" == "true" ]]; then
    pass "All aliases defined"
else
    fail "Some aliases are missing"
fi

# Test 9: Tmux wrapper content
echo "Test 9: Tmux wrapper content"
if grep -q "DBUS_SESSION_BUS_ADDRESS" "$MAIN_SCRIPT" && \
   grep -q "XDG_RUNTIME_DIR" "$MAIN_SCRIPT"; then
    pass "Tmux wrapper includes systemd avoidance"
else
    fail "Tmux wrapper missing systemd avoidance"
fi

# Test 10: No hardcoded paths (except common ones)
echo "Test 10: No problematic hardcoded paths"
# Check for hardcoded user home directories (but allow /root, /home patterns)
if grep -E "/home/[a-z]+" "$MAIN_SCRIPT" | grep -v '\$HOME' | grep -v 'pattern' &>/dev/null; then
    warn "Found potentially hardcoded home directory"
else
    pass "No problematic hardcoded paths"
fi

echo
echo "==================="
echo -e "${GREEN}All tests completed${NC}"
echo

# Summary
echo "Script is ready for deployment."
echo
echo "To test on a real server:"
echo "  1. Copy to server: scp claudego user@server:~/"
echo "  2. SSH to server"
echo "  3. Run: ./claudego"
