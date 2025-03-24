#!/bin/bash

# 依存パッケージがインストールされているか確認
if ! command -v curl &> /dev/null || ! command -v jq &> /dev/null; then
    echo "curl と jq が必要です。インストールしてください。"
    exit 1
fi

# GitHubリリースAPIのURL
REPO_API_URL="https://api.github.com/repos/kazuki0824/recisdb-rs/releases/latest"

# システムのアーキテクチャを取得
ARCH=$(dpkg --print-architecture)

# 最新リリース情報を取得
RELEASE_DATA=$(curl -s $REPO_API_URL)

# アーキテクチャに一致するdebパッケージのURLを取得
DEB_URL=$(echo "$RELEASE_DATA" | jq -r ".assets[] | select(.name | contains(\"$ARCH\")) | .browser_download_url")

# URLが見つからなかった場合の処理
if [ -z "$DEB_URL" ]; then
    echo "該当するアーキテクチャのdebパッケージが見つかりませんでした。"
    exit 1
fi

# 見つかったdebパッケージのURLを出力
curl -Lso/recisdb.deb "$DEB_URL"
