#!/bin/bash

# 1. Flutter SDKの取得（既存のフォルダがある場合はスキップ）
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# 2. パスを通す
export PATH="$PATH:$(pwd)/flutter/bin"

# 3. root実行の警告を無視する設定
export CHROME_EXECUTABLE=/usr/bin/google-chrome
flutter config --no-analytics

# 4. ビルド実行
# root警告で止まらないようにし、webビルドを明示的に行う
# stderrを無視せず、最後まで実行させるために "|| true" は使わず正常終了を目指す
flutter build web --release