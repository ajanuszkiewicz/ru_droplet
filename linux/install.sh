#!/bin/sh
# Install the Linux droplet for the current user (no root needed):
#   ~/.local/bin/rutorrent-droplet
#   ~/.local/share/applications/rutorrent-droplet.desktop
#   ~/.local/share/icons/hicolor/scalable/apps/rutorrent-droplet.svg
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
BIN="$HOME/.local/bin"

mkdir -p "$BIN" "$DATA/applications" "$DATA/icons/hicolor/scalable/apps"

install -m 755 "$DIR/rutorrent-droplet" "$BIN/rutorrent-droplet"
install -m 644 "$DIR/../icon/AppIcon.svg" "$DATA/icons/hicolor/scalable/apps/rutorrent-droplet.svg"

# Use an absolute Exec path: ~/.local/bin isn't on PATH in every desktop session.
sed "s|^Exec=rutorrent-droplet|Exec=$BIN/rutorrent-droplet|" \
	"$DIR/rutorrent-droplet.desktop" >"$DATA/applications/rutorrent-droplet.desktop"
chmod 644 "$DATA/applications/rutorrent-droplet.desktop"

command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database -q "$DATA/applications" || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q -t "$DATA/icons/hicolor" 2>/dev/null || true

for tool in curl secret-tool notify-send; do
	command -v "$tool" >/dev/null 2>&1 || echo "Warning: '$tool' not found; see README.md for dependencies."
done

echo "Installed: $BIN/rutorrent-droplet"
echo "Launcher:  $DATA/applications/rutorrent-droplet.desktop"
echo "Pin 'ruTorrent Droplet' to your dock/panel, or use Open With in your file manager."
