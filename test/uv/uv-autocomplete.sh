#!/bin/bash

# This test file will be executed against one of the scenarios devcontainer.json test that

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "uv autocomplete bash" [ -e /usr/share/bash-completion/completions/uv ]
check "uv autocomplete zsh"  [ -e /usr/share/zsh/vendor-completions/_uv ]
check "uv autocomplete fish" [ -e /usr/share/fish/completions/uv.fish ]

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults