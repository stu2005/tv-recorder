#!/bin/bash

API_URL="https://api.github.com/repos/rigaya/nvenc/releases/latest"
response=$(curl -s $API_URL)
if [ -z "$response" ]; then
  echo "GitHub APIからの応答がありません。"
  exit 1
fi
# 20.04 向けの .deb パッケージURLを取得
deb_url=$(echo "$response" | grep -i "browser_download_url" | grep -i "ubuntu" | grep "20.04" | grep ".deb" | cut -d '"' -f 4 | head -n 1)

if [ -z "$deb_url" ]; then
  echo "Ubuntu 20.04用のdebパッケージが見つかりませんでした。"
  exit 1
fi

# パッケージをダウンロード
curl -Lso /nvencc.deb "$deb_url"