#!/bin/zsh
set -e
cd "$(dirname "$0")"
xcodebuild -project "HTML_Memo.xcodeproj" -scheme "HTML Memo" -configuration Release -derivedDataPath build CODE_SIGNING_ALLOWED=NO
cp -R "build/Build/Products/Release/HTML Memo.app" ./
echo "완료: $(pwd)/HTML Memo.app"
