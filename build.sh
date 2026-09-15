#!/bin/sh
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/Applications/ruTorrent Droplet.app"

rm -rf "$DEST"
osacompile -o "$DEST" "$DIR/rutorrent_droplet.applescript"

# osacompile names the default icon after the compiled binary (droplet.icns);
# overwrite it in place so we don't need to touch Info.plist.
cp "$DIR/icon/AppIcon.icns" "$DEST/Contents/Resources/droplet.icns"
touch "$DEST"

echo "Built: $DEST"
echo "Drag it from ~/Applications onto your Dock."
