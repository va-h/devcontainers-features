#!/bin/bash

# This test file will be executed against one of the scenarios devcontainer.json test that

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "difft --version" difft --version | grep 0.55.0

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults