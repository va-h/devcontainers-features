#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

set -e

# Clean up
rm -rf /var/lib/apt/lists/*
UV_VERSION="${VERSION:-"latest"}"
AUTOCOMPLETION="${SHELLAUTOCOMPLETION:-"true"}"

architecture="$(uname -m)"
os="$(uname -s)"

# Normalize Operating System names
case "$os" in
    Linux*) os="unknown-linux-gnu";;
    Darwin*) os="apple-darwin";;
    *) echo "(!) OS ${os} unsupported"; exit 1 ;;
esac

# Normalize architecture names
case ${architecture} in
    x86_64 | x86-64 | x64 | amd64) architecture="x86_64";;
    i386 | i486 | i686 | i786 | x86) architecture="i686";;
    aarch64 | arm64 | armv8*) architecture="aarch64";;
    aarch32 | armv7* | armvhf*) architecture="armv7"; os="${os}eabihf";;
    ppc64) architecture=powerpc64;;
    ppc64le) architecture=powerpc64le;;
    s390x) architecture=s390x;;
    *) echo "(!) Architecture ${architecture} unsupported"; exit 1 ;;
esac

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Figure out correct version of a three part version number is not passed
find_version_from_git_tags() {
    local variable_name=$1
    local requested_version=${!variable_name}
    if [ "${requested_version}" = "none" ]; then return; fi
    local repository=$2
    local prefix=${3:-"tags/v"}
    local separator=${4:-"."}
    local last_part_optional=${5:-"false"}
    if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
        local escaped_separator=${separator//./\\.}
        local last_part
        if [ "${last_part_optional}" = "true" ]; then
            last_part="(${escaped_separator}[0-9]+)?"
        else
            last_part="${escaped_separator}[0-9]+"
        fi
        local regex="${prefix}\\K[0-9]+${escaped_separator}[0-9]+${last_part}$"
        local version_list="$(git ls-remote --tags ${repository} | grep -oP "${regex}" | tr -d ' ' | tr "${separator}" "." | sort -rV)"
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            declare -g ${variable_name}="$(echo "${version_list}" | head -n 1)"
        else
            set +e
            declare -g ${variable_name}="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
            set -e
        fi
    fi
    if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" > /dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${!variable_name}"
}

# Use semver logic to decrement a version number then look for the closest match
find_prev_version_from_git_tags() {
    local variable_name=$1
    local current_version=${!variable_name}
    local repository=$2
    # Normally a "v" is used before the version number, but support alternate cases
    local prefix=${3:-"tags/v"}
    # Some repositories use "_" instead of "." for version number part separation, support that
    local separator=${4:-"."}
    # Some tools release versions that omit the last digit (e.g. go)
    local last_part_optional=${5:-"false"}
    # Some repositories may have tags that include a suffix (e.g. actions/node-versions)
    local version_suffix_regex=$6
    # Try one break fix version number less if we get a failure. Use "set +e" since "set -e" can cause failures in valid scenarios.
    set +e
        major="$(echo "${current_version}" | grep -oE '^[0-9]+' || echo '')"
        minor="$(echo "${current_version}" | grep -oP '^[0-9]+\.\K[0-9]+' || echo '')"
        breakfix="$(echo "${current_version}" | grep -oP '^[0-9]+\.[0-9]+\.\K[0-9]+' 2>/dev/null || echo '')"

        if [ "${minor}" = "0" ] && [ "${breakfix}" = "0" ]; then
            ((major=major-1))
            declare -g ${variable_name}="${major}"
            # Look for latest version from previous major release
            find_version_from_git_tags "${variable_name}" "${repository}" "${prefix}" "${separator}" "${last_part_optional}"
        # Handle situations like Go's odd version pattern where "0" releases omit the last part
        elif [ "${breakfix}" = "" ] || [ "${breakfix}" = "0" ]; then
            ((minor=minor-1))
            declare -g ${variable_name}="${major}.${minor}"
            # Look for latest version from previous minor release
            find_version_from_git_tags "${variable_name}" "${repository}" "${prefix}" "${separator}" "${last_part_optional}"
        else
            ((breakfix=breakfix-1))
            if [ "${breakfix}" = "0" ] && [ "${last_part_optional}" = "true" ]; then
                declare -g ${variable_name}="${major}.${minor}"
            else
                declare -g ${variable_name}="${major}.${minor}.${breakfix}"
            fi
        fi
    set -e
}

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

check_packages curl ca-certificates tar jq
if ! type git > /dev/null 2>&1; then
    check_packages git
fi

uv_url="https://github.com/astral-sh/uv"

find_version_from_git_tags UV_VERSION "$uv_url" "tags/"

echo "Installing uv ${UV_VERSION}..."
mkdir /tmp/uv

uv_filename="uv-${architecture}-${os}.tar.gz"
echo "Downloading ${uv_filename}..."
curl -sSL -o ${uv_filename} "${uv_url}/releases/download/${UV_VERSION}/${uv_filename}"
tar -xzf ${uv_filename} --strip-components 1 -C /usr/local/bin
rm -rf /tmp/uv

# Clean up
rm -rf /var/lib/apt/lists/*

uv --version

enable_autocompletion() {
    command=$1
    ${command} bash >> /usr/share/bash-completion/completions/uv
    ${command} zsh >> /usr/share/zsh/vendor-completions/_uv
    ${command} fish >> /usr/share/fish/completions/uv.fish
}

if [ "$AUTOCOMPLETION"  = "true" ]; then
    mkdir -p /usr/share/fish/completions/
    enable_autocompletion "uv generate-shell-completion"

    # compability with older uv versions
    if command -v uvx &> /dev/null; then
        enable_autocompletion "uvx --generate-shell-completion"
    fi
fi

echo "Done!"
