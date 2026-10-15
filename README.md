# ruTorrent Droplet

A tiny macOS "droplet" app: drop `.torrent` files onto it (e.g. from your
Dock) and it uploads them to a [ruTorrent](https://github.com/Novik/ruTorrent)
server over HTTP, using ruTorrent's `php/addtorrent.php` endpoint.

It's a plain AppleScript compiled into a `.app` bundle with `osacompile` —
no third-party tools required to build or run it. Your ruTorrent password is
stored in the macOS Keychain, never in the script or in this repo.

There's also a [Linux version](#linux): a bash script plus a `.desktop`
launcher, using the same config file and the desktop keyring.

## Setup (macOS)

1. **Store your password in Keychain** (replace with your own username/password):

   ```sh
   security add-generic-password -a "<username>" -s "rutorrent-droplet" -w "<password>" -U
   ```

2. **Create a local config file** at `~/.config/rutorrent-droplet/config`:

   ```sh
   mkdir -p ~/.config/rutorrent-droplet
   cat > ~/.config/rutorrent-droplet/config <<EOF
   SERVER_URL=https://your-server/rutorrent/php/addtorrent.php
   KEYCHAIN_ACCOUNT=<username>
   KEYCHAIN_SERVICE=rutorrent-droplet
   DELETE_AFTER_ADD=true
   EOF
   chmod 600 ~/.config/rutorrent-droplet/config
   ```

   `SERVER_URL` should point at `php/addtorrent.php` under your ruTorrent
   install (e.g. `https://seed.example.com/rutorrent/php/addtorrent.php`).

   `DELETE_AFTER_ADD` is optional (default: off). When set to `true`, each
   dropped `.torrent` file is deleted after it's confirmed added — files that
   fail (auth error, rejected by server, etc.) are left in place.

3. **Build the app**:

   ```sh
   ./build.sh
   ```

   This compiles `rutorrent_droplet.applescript` into
   `~/Applications/ruTorrent Droplet.app`.

4. **Add it to your Dock**: open `~/Applications` in Finder and drag
   `ruTorrent Droplet.app` onto the Dock.

## Linux

The Linux version lives in `linux/`: `rutorrent-droplet` (a bash script that
takes `.torrent` paths as arguments), a `.desktop` launcher registered for
`application/x-bittorrent`, and `install.sh`.

**Dependencies:** `curl`, `secret-tool` (package `libsecret-tools` on
Debian/Ubuntu, `libsecret` on Fedora/Arch), and optionally `notify-send`
(`libnotify-bin` / `libnotify`) for desktop notifications.

1. **Store your password in the desktop keyring** (GNOME Keyring, or KWallet
   via its Secret Service support). `secret-tool` prompts for the password:

   ```sh
   secret-tool store --label="ruTorrent Droplet" service rutorrent-droplet account "<username>"
   ```

2. **Create the config file** exactly as in macOS step 2 above — same path
   (`~/.config/rutorrent-droplet/config`, or under `$XDG_CONFIG_HOME`) and
   same keys. `KEYCHAIN_ACCOUNT` / `KEYCHAIN_SERVICE` are used as the
   keyring's `account` / `service` attributes.

3. **Install** (per-user, no root):

   ```sh
   ./linux/install.sh
   ```

   This installs the script to `~/.local/bin/rutorrent-droplet`, the
   launcher to `~/.local/share/applications/`, and the icon into your icon
   theme.

4. **Use it** any of these ways:
   - Pin "ruTorrent Droplet" to your dock/panel and drop `.torrent` files on
     it (works in KDE Plasma, Ubuntu Dock/Dash to Dock, and most docks that
     accept file drops on launchers).
   - Right-click a `.torrent` file → Open With → ruTorrent Droplet (or make
     it the default app for torrents to add them with a double-click).
   - From a terminal: `rutorrent-droplet ~/Downloads/*.torrent`.

Results are reported as a desktop notification (and on stderr). Unlike the
macOS version, the password is passed to `curl` on stdin rather than on its
command line, so it doesn't show up in the process list.

## Usage (macOS)

Drop one or more `.torrent` files onto the Dock icon. A notification reports
how many were added, and names any that failed (e.g. wrong credentials, or
the server rejected the file).

## How it works

ruTorrent's `addtorrent.php` accepts a multipart upload of one or more
`.torrent` files and responds with an HTTP 302 redirect whose `Location`
header encodes the result (`result[]=Added` or `result[]=FailedFile`). The
script authenticates with HTTP Basic Auth, uploads via `curl`, and inspects
the redirect to determine success or failure — a plain 2xx/3xx status code
isn't enough on its own since ruTorrent redirects on both outcomes.

## Notes

- Only files ending in `.torrent` (case-insensitive) are processed if you
  drop a mix of files.
- If your ruTorrent server uses a self-signed TLS certificate, add `-k` to
  the `curl` command in `rutorrent_droplet.applescript` (or
  `linux/rutorrent-droplet`).
- `~/.config/rutorrent-droplet/config` is local to your machine and is not
  part of this repo (see `.gitignore`).
