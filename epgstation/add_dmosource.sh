#!/bin/bash

curl -Lso/dmo-keyring.deb https://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2024.9.1_all.deb
apt-get install -qy --no-install-recommends --no-install-suggests /dmo-keyring.deb

SOURCES_CONTENT=$(cat <<EOF
Types: deb
URIs: https://www.deb-multimedia.org
Suites: stable bullseye
Components: main non-free
Signed-By: /usr/share/keyrings/deb-multimedia-keyring.pgp

Types: deb
URIs: https://www.deb-multimedia.org
Suites: stable-backports bullseye-backports
Components: main
Signed-By: /usr/share/keyrings/deb-multimedia-keyring.pgp
EOF
)

echo "$SOURCES_CONTENT" >/etc/apt/sources.list.d/dmo.sources
apt-get update -q