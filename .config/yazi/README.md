# Yazi config

**Theme:** Cyberdream dark/light via **flavors** (auto dark/light by terminal appearance, like WezTerm). `theme.toml` sets `[flavor] dark = "cyberdream"` and `light = "cyberdream-light"`; Yazi detects terminal background at startup and loads the matching flavor from `flavors/`. Code preview in each flavor uses its own `tmtheme.xml` (copied from `~/.config/bat/themes/cyberdream.tmTheme`). Legacy single-theme files: `themes/cyberdream-light.toml` (reference only).

## Preview pane (right side)

The **right panel** is Yazi’s built-in preview: folder listing, code (bat), and images. No extra plugin is needed. **fzf-tab** is only for zsh tab completion when you open a shell inside Yazi (e.g. `!`).

**Requirements for preview to work:**

1. **chafa** – `brew install chafa` (image fallback; check `yazi --debug` → Dependencies.chafa).
2. **bat** – `brew install bat` (code/text preview; each flavor uses its own `tmtheme.xml` for in-app code highlighting).
3. **WezTerm env** – In `../wezterm/wezterm.lua`, WezTerm sets `XDG_CONFIG_HOME`, `TERM_PROGRAM=WezTerm`, and `PATH` with `/opt/homebrew/bin` first so Yazi and its subprocesses find `file`, `bat`, and `chafa`. Restart WezTerm after changing that config.

**Toggle panels:** Press **F9** to show/hide the preview (plugin in `plugins/toggle-view.yazi`). F7/F8 toggle parent/current. Or set **ratio** in `yazi.toml` to `[1, 4, 3]` (show) or `[1, 4, 0]` (hide) and restart.

## Config notes (yazi.toml)

- **Fetchers:** Do **not** override `[plugin] fetchers`. Use Yazi’s default so the built-in **mime** fetcher runs. Overriding with a custom `fetchers = [...]` caused “No mime fetcher” and broke image (and mime-based) previews.
- **Spotters / previewers:** Use **`url`** for path/glob rules, not `name`. For example: `{ url = "*/", run = "folder" }` for directories, `{ url = "*", run = "file" }` for fallback. The docs use `url` and `mime`; `name` is not the correct key here.

## If preview is empty again

- Restart WezTerm, then run Yazi from that session. Check `which file bat chafa`.
- Clear cache: `y --clear-cache` or `yazi --clear-cache`.
- Run `YAZI_LOG=debug yazi`, hover a folder and a PNG, quit, and check `~/.local/state/yazi/yazi.log` for `WARN`, `ERROR`, or “No mime fetcher”.

Optional deps: `file`, `ffmpeg`/`ffprobe`, `pdftoppm`, `magick`, `fzf`, `fd`, `rg`, `zoxide`, `jq`, `resvg`.
