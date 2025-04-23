#!/bin/bash

API_URL="https://api.github.com/repos/rigaya/nvenc/releases/latest"
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
  curl -Lso/ncencc.deb $highest_version_url
fi

curl -Lso/dmo-keyring.deb https://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2024.9.1_all.deb
apt-get -qy --no-install-recommends --no-install-suggests /dmo-keyring.deb

SOURCES_CONTENT=$(cat <<EOF
Types: deb
URIs: https://www.deb-multimedia.org
Suites: stable
Components: main non-free
Signed-By: /usr/share/keyrings/deb-multimedia-keyring.pgp

Types: deb
URIs: https://www.deb-multimedia.org
Suites: stable-backports
Components: main
Signed-By: /usr/share/keyrings/deb-multimedia-keyring.pgp
EOF
)

PREFERENCES=$(cat <<EOF
Package: *
Pin: origin www.deb-multimedia.org  
Pin-Priority: 500
EOF
)

echo "$SOURCES_CONTENT" >/etc/apt/sources.list.d/dmo.sources
echo "$PREFERENCES" >/etc/apt/preferences.d/demo.pref
apt-get update -q
