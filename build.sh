#!/bin/sh
set -e

DEST="$HOME/Applications/ruTorrent Droplet.app"

rm -rf "$DEST"
osacompile -o "$DEST" "$(dirname "$0")/rutorrent_droplet.applescript"

echo "Built: $DEST"
echo "Drag it from ~/Applications onto your Dock."
