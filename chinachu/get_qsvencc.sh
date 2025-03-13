#!/bin/bash

LATEST_RELEASE=$(gh api /repos/rigaya/QSVEnc/releases/latest)
if [ $? -ne 0 ]; then
  echo "Error: Failed to fetch latest release from GitHub API." >&2
  exit 1
fi

ASSETS=$(echo "$LATEST_RELEASE" | jq -r '.assets')
if [ $? -ne 0 ]; then
  echo "Error: Failed to parse assets from the release data." >&2
  exit 1
fi

DEB_FILES=$(echo "$ASSETS" | jq -r '.[] | select(.name | endswith(".deb")) | {name: .name, browser_download_url: .browser_download_url, ubuntu_version: (.name | split("_") | .[1] | split("-") | .[0]) // "" }' | jq -r 'sort_by(.ubuntu_version) | reverse')
if [ $? -ne 0 ]; then
  echo "Error: Failed to filter and sort .deb files." >&2
  exit 1
fi

if [ "$(echo "$DEB_FILES" | jq -r 'length')" = "0" ]; then
    echo "Error: No .deb files found." >&2
    exit 1
fi


HIGHEST_DEB=$(echo "$DEB_FILES" | jq -r '.[0]')
if [ $? -ne 0 ] || [ -z "$HIGHEST_DEB" ]; then
    echo "Error: could not select highest deb" >&2
    exit 1
fi

DEB_URL=$(echo "$HIGHEST_DEB" | jq -r '.browser_download_url')
if [ $? -ne 0 ] || [ -z "$DEB_URL" ]; then
    echo "Error: could not get url from deb data" >&2
    exit 1
fi

echo "Latest deb URL: $DEB_URL"
curl -Lo /qsvencc.deb "$DEB_URL"
if [ $? -ne 0 ]; then
  echo "Error: Failed to download the .deb file." >&2
  exit 1
fi