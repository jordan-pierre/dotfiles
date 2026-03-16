# Fastfetch – “Dig Dug” style logo

The screenshot in [scottmckendry/nix](https://github.com/scottmckendry/nix) and [cyberdream.nvim](https://github.com/scottmckendry/cyberdream.nvim) uses a **custom image** as the system-info logo (the little Dig Dug–style pixel art character). That image is **not** in the public repos; it’s a personal asset.

## How to get the same look

1. **Get a pixel-art image**  
   Use any small PNG you like (e.g. Dig Dug–style character, game sprite, mascot).  
   - Search for “dig dug pixel art png” or “pixel art character png transparent”.  
   - Or use a small (e.g. 80×64–200×200 px) PNG with transparent background.

2. **Put it in this folder**  
   Save the image as:
   ```text
   ~/.config/fastfetch/logo.png
   ```
   So fastfetch will use it (as set in `config.jsonc`).

3. **Run sysinfo**  
   You already have `alias sysinfo='fastfetch'`. Run:
   ```bash
   sysinfo
   ```
   Fastfetch will show your system info with the custom logo on the left.

## WezTerm

You’re using WezTerm. The config uses `"type": "auto"` so fastfetch picks a supported image protocol (e.g. sixel). If the image doesn’t show, try generating a config with image support and set the logo type explicitly:
```bash
fastfetch --gen-config
# Then in config, set "logo": { "type": "sixel", "source": "~/.config/fastfetch/logo.png", ... }
```

## Network on macOS

The **localip** module (network line) can fail to show on macOS due to default-route detection (e.g. loopback chosen). The config already sets `showAllIps: true` in the localip module to improve detection. If it still doesn’t appear, see [fastfetch#2127](https://github.com/fastfetch-cli/fastfetch/issues/2127).
