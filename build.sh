#!/bin/bash

set -euo pipefail

ROOT_DIR="$(dirname $(readlink -f "$0"))"
BUILD_DIR="$ROOT_DIR/build"
OUT_DIR="$ROOT_DIR/out"
REDBEAN_VERSION=2.2
FULLMOON_HASH=ec21400d166794f5887c22f0f9a122fcc320610d

mkdir -p $BUILD_DIR/

if [[ ! -f "$BUILD_DIR/redbean.com" ]]; then
  curl -o "$BUILD_DIR/redbean.com" "https://redbean.dev/redbean-$REDBEAN_VERSION.com"
  chmod +x "$BUILD_DIR/redbean.com"
fi

mkdir -p "$BUILD_DIR/.lua"

if [[ ! -f "$BUILD_DIR/fullmoon.lua" ]]; then
  curl -o "$BUILD_DIR/fullmoon.lua" "https://raw.githubusercontent.com/pkulchenko/fullmoon/$FULLMOON_HASH/fullmoon.lua"
fi

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

rm -rf "$BUILD_DIR/anime"
mkdir -p "$BUILD_DIR/anime"
cp "$ROOT_DIR/src/anime/app.lua" "$BUILD_DIR/anime/.init.lua"
cd "$BUILD_DIR/anime/"
cp ../redbean.com anime-app.com
mkdir -p .lua
cp ../fullmoon.lua ./.lua/fullmoon.lua
zip anime-app.com .init.lua .lua/fullmoon.lua
mv anime-app.com "$OUT_DIR/anime-app.com"

rm -rf "$BUILD_DIR/cubes"
mkdir -p "$BUILD_DIR/cubes"
cp -r "$ROOT_DIR/src/cubes/"* "$BUILD_DIR/cubes/"
cd "$BUILD_DIR/cubes/"
cp ../redbean.com root-app.com
zip root-app.com ./*.js ./*.html ./*.ico
mv root-app.com "$OUT_DIR/root-app.com"
