#!/bin/sh
# Regenerate AppIcon.icns from AppIcon.svg, preserving transparency.
#
# Requires librsvg (brew install librsvg). qlmanage/sips do NOT preserve
# SVG transparency reliably -- they can flatten it onto an opaque white
# background, which is why this uses rsvg-convert instead.
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
SVG="$DIR/AppIcon.svg"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

PNG="$WORK/icon_1024.png"
rsvg-convert -w 1024 -h 1024 --keep-aspect-ratio -o "$PNG" "$SVG"

ICONSET="$WORK/AppIcon.iconset"
mkdir -p "$ICONSET"
sips -z 16 16     "$PNG" --out "$ICONSET/icon_16x16.png" >/dev/null
sips -z 32 32     "$PNG" --out "$ICONSET/icon_16x16@2x.png" >/dev/null
sips -z 32 32     "$PNG" --out "$ICONSET/icon_32x32.png" >/dev/null
sips -z 64 64     "$PNG" --out "$ICONSET/icon_32x32@2x.png" >/dev/null
sips -z 128 128   "$PNG" --out "$ICONSET/icon_128x128.png" >/dev/null
sips -z 256 256   "$PNG" --out "$ICONSET/icon_128x128@2x.png" >/dev/null
sips -z 256 256   "$PNG" --out "$ICONSET/icon_256x256.png" >/dev/null
sips -z 512 512   "$PNG" --out "$ICONSET/icon_256x256@2x.png" >/dev/null
sips -z 512 512   "$PNG" --out "$ICONSET/icon_512x512.png" >/dev/null
cp "$PNG" "$ICONSET/icon_512x512@2x.png"

iconutil -c icns "$ICONSET" -o "$DIR/AppIcon.icns"

echo "Built: $DIR/AppIcon.icns"
