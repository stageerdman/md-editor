#!/bin/bash
# Regenerates Resources/AppIcon.icns from Scripts/generate_icon.swift.
# Only needs to be re-run if the icon design changes — build.sh just
# copies the committed .icns into the bundle, it doesn't call this.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

echo "==> rendering 1024x1024 icon"
swift "$ROOT_DIR/Scripts/generate_icon.swift" "$WORK_DIR/icon_1024.png"

echo "==> building .iconset"
ICONSET="$WORK_DIR/AppIcon.iconset"
mkdir "$ICONSET"
sips -z 16 16 "$WORK_DIR/icon_1024.png" --out "$ICONSET/icon_16x16.png" >/dev/null
sips -z 32 32 "$WORK_DIR/icon_1024.png" --out "$ICONSET/icon_16x16@2x.png" >/dev/null
sips -z 32 32 "$WORK_DIR/icon_1024.png" --out "$ICONSET/icon_32x32.png" >/dev/null
sips -z 64 64 "$WORK_DIR/icon_1024.png" --out "$ICONSET/icon_32x32@2x.png" >/dev/null
sips -z 128 128 "$WORK_DIR/icon_1024.png" --out "$ICONSET/icon_128x128.png" >/dev/null
sips -z 256 256 "$WORK_DIR/icon_1024.png" --out "$ICONSET/icon_128x128@2x.png" >/dev/null
sips -z 256 256 "$WORK_DIR/icon_1024.png" --out "$ICONSET/icon_256x256.png" >/dev/null
sips -z 512 512 "$WORK_DIR/icon_1024.png" --out "$ICONSET/icon_256x256@2x.png" >/dev/null
sips -z 512 512 "$WORK_DIR/icon_1024.png" --out "$ICONSET/icon_512x512.png" >/dev/null
cp "$WORK_DIR/icon_1024.png" "$ICONSET/icon_512x512@2x.png"

echo "==> building AppIcon.icns"
iconutil -c icns "$ICONSET" -o "$ROOT_DIR/Resources/AppIcon.icns"

echo "==> done: Resources/AppIcon.icns"
