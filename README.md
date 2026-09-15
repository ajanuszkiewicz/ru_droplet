# ruTorrent Droplet

A tiny macOS "droplet" app: drop `.torrent` files onto it (e.g. from your
Dock) and it uploads them to a [ruTorrent](https://github.com/Novik/ruTorrent)
server over HTTP, using ruTorrent's `php/addtorrent.php` endpoint.

It's a plain AppleScript compiled into a `.app` bundle with `osacompile` —
no third-party tools required to build or run it. Your ruTorrent password is
stored in the macOS Keychain, never in the script or in this repo.

## Setup

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
   EOF
   chmod 600 ~/.config/rutorrent-droplet/config
   ```

   `SERVER_URL` should point at `php/addtorrent.php` under your ruTorrent
   install (e.g. `https://seed.example.com/rutorrent/php/addtorrent.php`).

3. **Build the app**:

   ```sh
   ./build.sh
   ```

   This compiles `rutorrent_droplet.applescript` into
   `~/Applications/ruTorrent Droplet.app`.

4. **Add it to your Dock**: open `~/Applications` in Finder and drag
   `ruTorrent Droplet.app` onto the Dock.

## Usage

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
  the `curl` command in `rutorrent_droplet.applescript`.
- `~/.config/rutorrent-droplet/config` is local to your machine and is not
  part of this repo (see `.gitignore`).
