#!/bin/bash

API_URL="https://api.github.com/repos/rigaya/vceenc/releases/latest"
response=$(curl -s "$API_URL")

if [ -z "$response" ]; then
  echo "GitHub APIからの応答がありません。"
  exit 1
fi

# Ubuntu 20.04 用のdebパッケージURLを抽出
deb_url=$(echo "$response" | grep -i "browser_download_url" | grep -i "ubuntu20.04" | grep ".deb" | cut -d '"' -f 4)

if [ -z "$deb_url" ]; then
  echo "Ubuntu 20.04 用のdebパッケージが見つかりませんでした。"
  exit 1
fi

# パッケージをダウンロード
curl -Lso/vceencc.deb "$deb_url"