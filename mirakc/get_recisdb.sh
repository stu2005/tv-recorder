#!/bin/bash

if ! command -v curl &> /dev/null || ! command -v jq &> /dev/null; then
    echo "curl と jq が必要です。インストールしてください。"
    exit 1
fi
REPO_API_URL="https://api.github.com/repos/kazuki0824/recisdb-rs/releases/latest"
ARCH=$(dpkg --print-architecture)
RELEASE_DATA=$(curl -s $REPO_API_URL)
DEB_URL=$(echo "$RELEASE_DATA" | jq -r ".assets[] | select(.name | contains(\"$ARCH\")) | .browser_download_url")
if [ -z "$DEB_URL" ]; then
    echo "該当するアーキテクチャのdebパッケージが見つかりませんでした。"
    exit 1
fi
curl -Lo/recisdb.deb "$DEB_URL"