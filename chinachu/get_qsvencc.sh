#!/bin/bash

# 1. gh api の出力確認
LATEST_RELEASE=$(gh api /repos/rigaya/QSVEnc/releases/latest)
if [ $? -ne 0 ]; then
  echo "Error: Failed to fetch latest release from GitHub API." >&2
  exit 1
fi

# (デバッグ) gh api の出力をファイルに保存
echo "$LATEST_RELEASE" > latest_release.json
echo "DEBUG: Saved gh api output to latest_release.json" >&2


# 2. ASSETS 変数の内容確認
ASSETS=$(echo "$LATEST_RELEASE" | jq -r '.assets')
if [ $? -ne 0 ]; then
  echo "Error: Failed to parse assets from the release data." >&2
  exit 1
fi

# (デバッグ) ASSETS の内容を整形して表示
echo "DEBUG: ASSETS content:" >&2
echo "$ASSETS" | jq . >&2


# 3. DEB_FILES 変数生成部分 (段階的な確認)
echo "DEBUG: Processing DEB_FILES..." >&2

# ステップ1: .deb で終わるファイル名のみ抽出 (デバッグ)
DEB_FILES_STEP1=$(echo "$ASSETS" | jq -r '.[] | select(.name | endswith(".deb"))')
echo "DEBUG: DEB_FILES_STEP1:" >&2
echo "$DEB_FILES_STEP1" | jq . >&2 # 整形して表示
if [ $? -ne 0 ]; then
    echo "ERROR: Step 1 Failed" >&2
    exit 1
fi

# ステップ2: オブジェクトに変換 (デバッグ)
DEB_FILES_STEP2=$(echo "$ASSETS" | jq -r '.[] | select(.name | endswith(".deb")) | {name: .name, browser_download_url: .browser_download_url, ubuntu_version: (.name | split("_") | .[1] | split("-") | .[0]) // "" }')
echo "DEBUG: DEB_FILES_STEP2:" >&2
echo "$DEB_FILES_STEP2" | jq . >&2  # 整形して表示
if [ $? -ne 0 ]; then
    echo "ERROR: Step 2 Failed" >&2
    exit 1
fi


# ステップ3: ubuntu_version でソート (問題の箇所)
DEB_FILES=$(echo "$ASSETS" | jq -r '.[] | select(.name | endswith(".deb")) | {name: .name, browser_download_url: .browser_download_url, ubuntu_version: (.name | split("_") | .[1] | split("-") | .[0]) // "" }' | jq -r 'sort_by(.ubuntu_version) | reverse')

if [ $? -ne 0 ]; then
  echo "Error: Failed to filter and sort .deb files." >&2
  echo "DEBUG: DEB_FILES (before sort):" >&2  # ソート前の状態
  echo "$DEB_FILES_STEP2" | jq . >&2
  exit 1
fi

# 空の配列が返された場合の処理
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