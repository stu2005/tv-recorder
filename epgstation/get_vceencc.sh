#!/bin/bash

API_URL="https://api.github.com/repos/rigaya/VCEEnc/releases/latest"
response=$(curl -s $API_URL)
if [ -z "$response" ]; then
  echo "GitHub APIからの応答がありません。"
  exit 1
fi
deb_urls=$(echo "$response" | grep -i "browser_download_url" | grep -i "ubuntu" | grep ".deb" | cut -d '"' -f 4)
ubuntu_version_regex='Ubuntu([0-9]+\.[0-9]+)'
highest_ubuntu_version=""
highest_version_url=""
for url in $deb_urls; do
  ubuntu_version=$(echo "$url" | grep -oE "$ubuntu_version_regex" | grep -oE '[0-9]+\.[0-9]+')
  if [ -z "$ubuntu_version" ]; then
    continue
  fi
  if [ -z "$highest_ubuntu_version" ] || [ "$(echo -e "$ubuntu_version\n$highest_ubuntu_version" | sort -V | tail -n 1)" = "$ubuntu_version" ]; then
    highest_ubuntu_version=$ubuntu_version
    highest_version_url=$url
  fi
done
if [ -z "$highest_version_url" ]; then
  echo "対応するUbuntu用のdebパッケージが見つかりませんでした。"
else
  curl -Lso/vceencc.deb $highest_version_url
fi

curl -Lso/rocm.gpg https://repo.radeon.com/rocm/rocm.gpg.key
echo <<EOF
Types: deb
URIs: https://repo.radeon.com/amdgpu/latest/ubuntu/ https://repo.radeon.com/rocm/apt/latest/
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: main
Architectures: amd64
Signed-By: /rocm.gpg
EOF > /etc/apt/sources.list.d/amdgpu.sources
apt-get update -q