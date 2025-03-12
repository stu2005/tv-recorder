#!/bin/bash
LATEST_RELEASE=$(gh api /repos/rigaya/QSVEnc/releases/latest)
ASSETS=$(echo "$LATEST_RELEASE" | jq -r '.assets')
DEB_FILES=$(echo "$ASSETS" | jq -r '.[] | select(.name | endswith(".deb")) | {name: .name, browser_download_url: .browser_download_url, ubuntu_version: (.name | split("_") | .[1] | split("-") | .[0]) }' | sort -t "-" -k 3 -r)
HIGHEST_DEB=$(echo "$DEB_FILES" | jq -r '.[0]')
DEB_URL=$(echo "$HIGHEST_DEB" | jq -r '.browser_download_url')
echo "Latest deb URL: $DEB_URL"
curl -Lo/qsvencc.deb "$DEB_URL"