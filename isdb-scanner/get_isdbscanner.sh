#!/bin/bash

set -e

REPO="tsukumijima/ISDBScanner"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
ARCH=$(uname -m)

# アーキテクチャに対応したファイル名を設定
case "$ARCH" in
    x86_64)
        FILENAME="isdb-scanner"
        ;;
    aarch64|armv7l)
        FILENAME="isdb-scanner-arm"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# 最新のタグ名を取得
echo "Fetching latest release info..."
TAG_NAME=$(curl -s "$API_URL" | jq -r .tag_name)

if [ -z "$TAG_NAME" ] || [ "$TAG_NAME" == "null" ]; then
    echo "Failed to get latest release tag."
    exit 1
fi

DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${TAG_NAME}/${FILENAME}"

curl -Lso/usr/local/bin/isdb-scanner "$DOWNLOAD_URL"
chmod +x /usr/local/bin/isdb-scanner