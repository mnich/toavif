# toavif

**toavif** is a multi-threaded CLI tool written in Bash, designed for the batch conversion of images (JPG/JPEG, PNG) into the modern and highly efficient AVIF format. The script is engineered for maximum performance, automation (e.g., via cron), and complete file safety.

It is the AVIF counterpart of [towebp](https://github.com/mnich/towebp).

## ✨ Features

- **Multi-threading** – detects the number of logical CPU cores (macOS/Linux) and runs `avifenc` jobs in parallel via `xargs -P`. Each encoder runs single-threaded, so parallel jobs do not compete for CPU.
- **Cron-ready** – built to run in the background. Files that already have an `.avif` counterpart are skipped, so periodic scans (e.g. of `~/Downloads`) are cheap. A lock prevents overlapping runs.
- **Safe paths** – full support for file names containing spaces or special characters.
- **Disk cleanup** – the optional `--delete` flag removes original files **only** after a successful conversion (checked via the `avifenc` exit code).
- **No partial files** – images are written to a temporary file first and moved into place only when conversion succeeds.

## 📦 Installation (macOS / Linux)

The tool is distributed as a Homebrew package. All dependencies are installed automatically: the formula depends on the `libavif` package (which provides `avifenc`), and the remaining tools (`bash`, `find`, `xargs`) are part of the operating system.

```bash
brew tap mnich/tools
brew install toavif
```

### Manual installation

If `avifenc` is missing and Homebrew is available, `toavif` installs the `libavif` package automatically on first run. Without Homebrew, install it with your system package manager (e.g. `sudo apt install libavif-bin`).

```bash
curl -fsSL https://raw.githubusercontent.com/mnich/toavif/main/toavif -o /usr/local/bin/toavif
chmod +x /usr/local/bin/toavif
```

## 🚀 Usage

When run without arguments, `toavif` scans `~/Downloads` (recursively), uses quality 60, encoder speed 6 and as many parallel jobs as there are logical CPU cores.

```bash
toavif [OPTIONS]
```

### Options

| Option | Description |
| --- | --- |
| `-q`, `--quality <0-100>` | AVIF quality (default: `60`) |
| `-s`, `--speed <0-10>` | Encoder speed: `0` = slowest / smallest files, `10` = fastest (default: `6`) |
| `-d`, `--dir <path>` | Directory with images (default: `~/Downloads`) |
| `-t`, `--threads <n>` | Number of parallel jobs (default: number of logical cores) |
| `--max-depth <n>` | Descend at most `n` directory levels; `1` = only the directory itself (default: unlimited) |
| `--newer-than <file>` | Only process images added or changed after `<file>` was last changed |
| `--min-age <minutes>` | Skip images modified less than `<minutes>` ago, e.g. still downloading (default: `0`) |
| `--delete` | Delete the original `.jpg` / `.jpeg` / `.png` after a successful conversion |
| `-v`, `--version` | Show version |
| `-h`, `--help` | Show help |

AVIF quality values are not equivalent to WebP or JPEG ones – quality `60` in AVIF typically gives results visually comparable to WebP at `80`, with smaller files.

### Examples

Convert the `~/Pictures` folder with quality 65 using 8 threads, keeping the originals:

```bash
toavif -q 65 -d ~/Pictures -t 8
```

Convert `~/Downloads` with maximum compression (slow) and delete the originals afterwards:

```bash
toavif -s 0 --delete
```

> **Note:** an image is skipped when an `.avif` file with the same base name already exists – an existing `.avif` is never overwritten, and with `--delete` the original of a skipped image is kept. If a directory contains e.g. `photo.jpg` and `photo.png`, only one of them is converted; the other stays untouched.

## ⏱ Automation (cron)

`toavif` can convert newly downloaded images in the background. Open your crontab:

```bash
crontab -e
```

and add the following line to run it every minute (use the absolute path to the binary – `/opt/homebrew/bin/toavif` on Apple Silicon, `/usr/local/bin/toavif` on Intel Macs – and to the directory):

```cron
* * * * * /opt/homebrew/bin/toavif -d /Users/YOUR_USERNAME/Downloads --max-depth 1 --newer-than /Users/YOUR_USERNAME/.toavif-since --min-age 1 > /tmp/toavif_cron.log 2>&1
```

Before enabling it, create the reference file once: `touch ~/.toavif-since`. Together the options make the job:

- `--max-depth 1` – look only at `Downloads` itself, not at extracted archives or project folders inside it,
- `--newer-than` – ignore images that were already there when the job was set up (only new arrivals are converted),
- `--min-age 1` – wait until a file has not changed for a minute, so half-downloaded images are never picked up.

Add `--delete` if the originals should be removed after conversion.

Watch the log live with:

```bash
tail -f /tmp/toavif_cron.log
```

The script extends `PATH` with the standard Homebrew locations, so `avifenc` is found even in cron's minimal environment.

> **Using together with towebp:** if you run both `towebp` and `toavif` on the same directory, do **not** pass `--delete` to either of them – whichever runs first would remove the originals before the other one converts them.

> **macOS:** to let cron access `~/Downloads`, grant **Full Disk Access** to `/usr/sbin/cron` in *System Settings → Privacy & Security*.

## 🍺 Publishing a release to Homebrew

The formula lives in the shared tap repository [`mnich/homebrew-tools`](https://github.com/mnich/homebrew-tools), next to `towebp`. A template is kept in [`homebrew/toavif.rb`](homebrew/toavif.rb).

1. Bump `VERSION` in `toavif`, commit, and create a GitHub release with a tag, e.g. `v1.0.0`.
2. Compute the SHA256 of the release tarball:

   ```bash
   curl -sL https://github.com/mnich/toavif/archive/refs/tags/v1.0.0.tar.gz | shasum -a 256
   ```

3. In `homebrew-tools`, update `url` and `sha256` in `Formula/toavif.rb` and push.
4. Users get the new version with `brew upgrade toavif`.

## 📄 License

This project is released under the [MIT License](LICENSE).
