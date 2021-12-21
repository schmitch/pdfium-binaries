#!/bin/bash -eux

PATCHES="$PWD/patches"
SOURCE="${PDFium_SOURCE_DIR:-pdfium}"
OS="${PDFium_TARGET_OS:?}"

pushd "${SOURCE}"

git apply -v "$PATCHES/shared_library.patch"
git apply -v "$PATCHES/public_headers.patch"

[ "${PDFium_V8:-}" == "enabled" ] && git apply -v "$PATCHES/v8_init.patch"

case "$OS" in
  android)
    git -C build apply -v "$PATCHES/android/build.patch"
    ;;
  
  ios)
    git apply -v "$PATCHES/ios/pdfium.patch"
    git -C build apply -v "$PATCHES/ios/build.patch"
    git -C third_party/libjpeg_turbo apply -v "$PATCHES/ios/libjpeg_turbo.patch"
    ;;

  win)
    git apply -v "$PATCHES/win/pdfium.patch"
    git -C build apply -v "$PATCHES/win/build.patch"

    VERSION=${PDFium_VERSION:-0.0.0.0}
    YEAR=$(date +%Y)
    VERSION_CSV=${VERSION//./,}
    export YEAR VERSION VERSION_CSV
    envsubst < "$PATCHES/win/resources.rc" > "resources.rc"
    ;;
esac

popd
