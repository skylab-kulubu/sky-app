#!/bin/sh
# Xcode Cloud post-clone adımı.
#
# Xcode Cloud makinesinde Flutter kurulu değil ve `ios/Flutter/ephemeral/`
# (Generated.xcconfig ve FlutterGeneratedPluginSwiftPackage) `.gitignore`'da
# olduğu için repoda yok. Bu dosyalar Flutter tarafından üretiliyor; üretilmezse
# `xcodebuild` paketi bulamayıp düşüyor.
#
# Proje Swift Package Manager kullanıyor, CocoaPods yok; `pod install` adımı
# bilerek eklenmedi.
set -e

# Flutter sürümü CI ile aynı kalmalı (.github/workflows/ci.yml FLUTTER_VERSION).
FLUTTER_VERSION=3.47.1

cd "$CI_PRIMARY_REPOSITORY_PATH"

git clone https://github.com/flutter/flutter.git --depth 1 -b "$FLUTTER_VERSION" "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

flutter --version
flutter precache --ios
flutter pub get

# Üretilen iOS dosyalarını oluşturur; derlemeyi Xcode Cloud yapıyor.
flutter build ios --release --no-codesign --config-only

exit 0
