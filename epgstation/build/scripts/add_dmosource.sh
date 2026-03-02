#!/bin/bash

curl -Lso/dmo-keyring.deb https://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2024.9.1_all.deb
apt-get install -qy --no-install-recommends --no-install-suggests /dmo-keyring.deb
rm -rf /dmo-keyring.deb

SOURCES_CONTENT=$(cat <<EOF
Types: deb deb-src
URIs: https://www.deb-multimedia.org/
Suites: trixie bookworm bullseye
Components: main non-free
Signed-By: /usr/share/keyrings/deb-multimedia-keyring.pgp

Types: deb deb-src
URIs: https://www.deb-multimedia.org/
Suites: bookworm-backports bullseye-backports
Components: main
Signed-By: /usr/share/keyrings/deb-multimedia-keyring.pgp

Types: deb deb-src
URIs: http://deb.debian.org/debian/
Suites: bookworm bookworm-updates
Components: contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg


Types: deb deb-src
URIs: http://deb.debian.org/debian/
Suites: trixie
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
)

PREFERENCE=$(cat <<EOF
Package: *
Pin: release n=trixie
Pin-Priority: 100

Package: libc6 libc-bin libstdc++6 base-files
Pin: release n=trixie
Pin-Priority: 500
EOF
)

echo "$SOURCES_CONTENT" >/etc/apt/sources.list.d/dmo.sources
echo "$PREFERENCE" >/etc/apt/preferences.d/dmo.pref
sed -i -e "s/Types: deb/Types: deb deb-src/g" /etc/apt/sources.list.d/debian.sources
apt-get update -q