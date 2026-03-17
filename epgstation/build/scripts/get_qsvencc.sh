#!/bin/bash

API_URL="https://api.github.com/repos/rigaya/qsvenc/releases/latest"

# 1. APIからレスポンス取得
response=$(curl -s "$API_URL")

# 2. 応答が空でないか確認 (古い [ ] 形式で記述)
if [ -z "$response" ]; then
  echo "GitHub APIからの応答がありません。"
  exit 1
fi

# 3. エラーメッセージ（Rate Limit等）が含まれていないか確認
if echo "$response" | grep -q "message"; then
  echo "APIエラーが発生しました。"
  echo "$response"
  exit 1
fi

# 4. 新しい命名規則に合わせてURLを抽出
# v8.06からは "Ubuntu" の文字が消え "qsvencc_8.06_amd64.deb" のようになっています
# "_amd64.deb" で終わる行を抽出し、URL部分を切り出し
target_url=$(echo "$response" | grep "browser_download_url" | grep "_amd64\.deb" | cut -d '"' -f 4 | head -n 1)

if [ -z "$target_url" ]; then
  echo "対応するdebパッケージが見つかりませんでした。"
  exit 1
fi

echo "ダウンロード中: $(basename "$target_url")"

# 5. ダウンロード実行
curl -Ls -o /qsvencc.deb "$target_url"

if [ $? -eq 0 ]; then
  echo "ダウンロード完了: /qsvencc.deb"
else
  echo "ダウンロード失敗"
  exit 1
fi