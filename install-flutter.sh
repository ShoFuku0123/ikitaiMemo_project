#!/bin/bash
# Flutter SDKがない場合はクローン、ある場合は更新
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# パスを通す
export PATH="$PATH:$(pwd)/flutter/bin"

# ビルド実行
flutter doctor
flutter build web --release