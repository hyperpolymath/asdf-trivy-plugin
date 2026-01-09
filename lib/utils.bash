#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
set -euo pipefail

TOOL_NAME="trivy"
TOOL_REPO="aquasecurity/trivy"
BINARY_NAME="trivy"

fail() {
  echo -e "\e[31mFail:\e[m $*" >&2
  exit 1
}

get_platform() {
  local os="$(uname -s)"
  case "$os" in
    Darwin) echo "Darwin" ;;
    Linux) echo "Linux" ;;
    *) fail "Unsupported OS: $os" ;;
  esac
}

get_platform_lower() {
  local os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  case "$os" in
    darwin) echo "darwin" ;;
    linux) echo "linux" ;;
    *) fail "Unsupported OS: $os" ;;
  esac
}

get_arch() {
  local arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    i386|i686) echo "386" ;;
    *) fail "Unsupported architecture: $arch" ;;
  esac
}

get_arch_alt() {
  local arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) echo "x86_64" ;;
    aarch64|arm64) echo "aarch64" ;;
    *) fail "Unsupported architecture: $arch" ;;
  esac
}

list_all_versions() {
  curl -sL "https://api.github.com/repos/$TOOL_REPO/releases" |
    grep -oE '"tag_name": "[^"]+"' |
    sed 's/"tag_name": "v\?//' |
    sed 's/"//' |
    grep -E '^[0-9]' |
    sort -V
}

get_download_url() {
  local version="$1"
  local os="$(get_platform)"
  local os_lower="$(get_platform_lower)"
  local arch="$(get_arch)"
  local arch_alt="$(get_arch_alt)"

  # Build asset name with various patterns
  local asset_name
  asset_name="$(echo 'trivy_{version}_{os}-{arch}.tar.gz' | sed "s/{version}/$version/g" | sed "s/{os}/$os/g" | sed "s/{arch}/$arch/g")"

  # Try different URL patterns
  local urls=(
    "https://github.com/$TOOL_REPO/releases/download/v$version/$asset_name"
    "https://github.com/$TOOL_REPO/releases/download/$version/$asset_name"
  )

  for url in "${urls[@]}"; do
    if curl -sfLI "$url" >/dev/null 2>&1; then
      echo "$url"
      return
    fi
  done

  # Fallback - try lowercase os
  asset_name="$(echo 'trivy_{version}_{os}-{arch}.tar.gz' | sed "s/{version}/$version/g" | sed "s/{os}/$os_lower/g" | sed "s/{arch}/$arch/g")"
  echo "https://github.com/$TOOL_REPO/releases/download/v$version/$asset_name"
}

download_release() {
  local version="$1"
  local download_path="$2"
  local url
  url="$(get_download_url "$version")"

  echo "Downloading $TOOL_NAME $version from $url"
  local archive="$download_path/archive.tar.gz"
  curl -fsSL "$url" -o "$archive" || fail "Download failed"

  tar -xzf "$archive" -C "$download_path" --strip-components=1 2>/dev/null || \
    tar -xzf "$archive" -C "$download_path" 2>/dev/null || \
    fail "Extract failed"

  rm -f "$archive"

  # Find binary
  if [[ -f "$download_path/$BINARY_NAME" ]]; then
    chmod +x "$download_path/$BINARY_NAME"
  elif [[ -f "$download_path/bin/$BINARY_NAME" ]]; then
    mv "$download_path/bin/$BINARY_NAME" "$download_path/"
    chmod +x "$download_path/$BINARY_NAME"
  else
    # Search for binary
    local found
    found="$(find "$download_path" -name "$BINARY_NAME" -type f | head -1)"
    if [[ -n "$found" ]]; then
      mv "$found" "$download_path/$BINARY_NAME"
      chmod +x "$download_path/$BINARY_NAME"
    fi
  fi
}

install_version() {
  local version="$1"
  local install_path="$2"

  mkdir -p "$install_path/bin"
  cp "$ASDF_DOWNLOAD_PATH/$BINARY_NAME" "$install_path/bin/" || fail "Binary not found"
  chmod +x "$install_path/bin/$BINARY_NAME"
}
