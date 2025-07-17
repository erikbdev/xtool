#!/bin/bash

set -e
shopt -s nullglob

cd "$(dirname "$0")"

if ! command -v fusermount &>/dev/null; then
    # Docker doesn't support FUSE
    export APPIMAGE_EXTRACT_AND_RUN=1
fi

rm -rf staging/tmp
mkdir -p staging/tmp staging/linuxdeploy

SWIFT_RESOURCE_PATH="$(swift -print-target-info | grep '"runtimeResourcePath"' | cut -d '"' -f4)" swift build --package-path .. -c release --product XToolProductTypes
swift build --package-path .. -c release --product xtool --static-swift-stdlib
bin="$(swift build --package-path .. -c release --show-bin-path)"
strip "${bin}/xtool"
strip --strip-debug "${bin}/libXToolProductTypes.so"

curr_git_info="$(curl -fsSL https://api.github.com/repos/linuxdeploy/linuxdeploy/git/refs/tags/continuous)"
curr_arch="$(uname -m)"

if [[ -f staging/linuxdeploy/git.json ]]; then
    if ! cmp -s staging/linuxdeploy/git.json <(echo "$curr_git_info"); then
        echo "[info] Updating linuxdeploy"
        rm -rf staging/linuxdeploy/linuxdeploy.AppImage
    fi
else
    echo "[info] Downloading linuxdeploy"
    rm -rf staging/linuxdeploy/linuxdeploy.AppImage
fi

if [[ ! -f staging/linuxdeploy/linuxdeploy.AppImage ]]; then
    curl -fsSL "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-${curr_arch}.AppImage" \
        -o staging/linuxdeploy/linuxdeploy.AppImage
    chmod +x staging/linuxdeploy/linuxdeploy.AppImage
    echo "$curr_git_info" > staging/linuxdeploy/git.json
fi

mkdir -p staging/tmp/AppDir/usr/bin
mkdir -p staging/tmp/AppDir/usr/lib
find "${bin}"/ -name '*.resources' -print0 | xargs -0 -I {} cp -a {} "${PWD}/staging/tmp/AppDir/usr/bin/"

export LINUXDEPLOY_OUTPUT_VERSION="${XTOOL_VERSION:-unversioned}"
export LDAI_OUTPUT="staging/tmp/xtool-${curr_arch}.AppImage"
export LDAI_UPDATE_INFORMATION="gh-releases-zsync|xtool-org|xtool|latest|xtool-${curr_arch}.AppImage.zsync"
./staging/linuxdeploy/linuxdeploy.AppImage \
    --appdir staging/tmp/AppDir \
    --output appimage \
    -e "${bin}/xtool" \
    -d xtool.desktop \
    -i xtool.png \
    -l "${bin}/libXToolProductTypes.so"
mkdir -p packages
mv -f "staging/tmp/xtool-${curr_arch}.AppImage" "./xtool-${curr_arch}.AppImage.zsync" packages/

rm -rf staging/tmp

echo "[info] Success!"
