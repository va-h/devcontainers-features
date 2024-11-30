#!/bin/bash

# This test file will be executed against one of the scenarios devcontainer.json test that

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "uv autocomplete bash" cat ~/.bashrc | grep "eval \"\$(uv" | grep bash
check "uv autocomplete zsh" cat ~/.zshrc | grep "eval \"\$(uv" | grep zsh

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults