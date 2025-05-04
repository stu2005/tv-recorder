#!/bin/bash

API_URL="https://api.github.com/repos/rigaya/vceenc/releases/latest"
response=$(curl -s "$API_URL")

if [ -z "$response" ]; then
  echo "GitHub APIからの応答がありません。"
  exit 1
fi

# Ubuntu 20.04 向けの .deb パッケージURLを抽出
deb_url=$(echo "$response" | grep -i "browser_download_url" | grep -i "ubuntu" | grep "20.04" | grep ".deb" | cut -d '"' -f 4 | head -n 1)

if [ -z "$deb_url" ]; then
  echo "Ubuntu 20.04用のdebパッケージが見つかりませんでした。"
  exit 1
fi

# パッケージをダウンロード
curl -Lso /vceencc.deb "$deb_url"

# ROCm GPG鍵の取得
curl -Lso /rocm.gpg https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/rocm.gpg

# APT ソースファイルの作成 (focal向けに修正)
SOURCES_CONTENT=$(cat <<EOF
Types: deb
URIs: https://repo.radeon.com/amdgpu/latest/ubuntu/ https://repo.radeon.com/rocm/apt/latest/
Suites: focal
Components: main proprietary
Architectures: amd64
Signed-By: /rocm.gpg
EOF
)

echo "$SOURCES_CONTENT" > /etc/apt/sources.list.d/amdgpu.sources
apt-get update -q