# Jordan's Dotfiles (Stow + Shell Scripts)

A cross-platform dotfile management setup using [GNU Stow](https://www.gnu.org/software/stow/) with shell-based conditionals for work, personal, and machine-specific environments.

## Features

- **Cross-platform support**: Works on both macOS and Linux
- **Environment-specific configurations**: Automatically adapts based on machine type and OS
- **Machine-specific configurations**: Local-only configs that don't sync
- **Shell-based conditionals**: Uses native zsh conditionals instead of templating
- **Simple and transparent**: Standard Unix tools with no magic
- **Secure**: Personal details in untracked files, never committed

## Quick Start

### Automated Setup (Recommended)

**Prerequisites:** **macOS** — [Homebrew](https://brew.sh/) for installs the script runs. **Linux** — `sudo` and **dnf** (Fedora-family) or **apt** (Debian/Ubuntu); the script does **not** use Homebrew on Linux.

```bash
# Clone the repository
git clone https://github.com/jordan-pierre/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run setup script (OS detection, interactive prompts, installs deps — see below)
./scripts/setup.sh

# Create symlinks
stow .
```

Setup asks for **machine type**, **git name/email**, **shell** (default **zsh** or **Nushell** on top of zsh), optional **vivid**, **fzf**, and related CLI tools, **Nerd Font**, and **primary terminal** (**WezTerm** default vs **Other / OS Default**). **Homebrew** is used on macOS; **dnf/apt** on Linux (no Homebrew there). See [Setting Up New Machines](#setting-up-new-machines) for the full list.

### Manual Setup

1. **Install stow**:
   ```bash
   # macOS
   brew install stow
   
   # Linux (Fedora)
   sudo dnf install stow
   
   # Linux (Ubuntu/Debian)
   sudo apt install stow
   ```

2. **Clone and configure**:
   ```bash
   git clone https://github.com/jordan-pierre/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ./scripts/setup.sh
   stow .
   ```

## Configuration Overview

### Managed Configurations

All configurations are managed by stow and synced across machines:

- **zsh**: Shell configuration with environment-specific conditionals
- **nushell**: Interactive shell config (config.nu, env.nu); optional via `./scripts/setup.sh` (default setup is **zsh**; **Nushell** adds `personal.nu` + tooling). **WezTerm** launches **nu** only when you choose Nushell **and** WezTerm (via `~/.config/wezterm/local.lua`); otherwise the repo defaults to **zsh**
- **starship**: Modern shell prompt configuration
- **git**: Version control settings (user details set by setup script)
- **wezterm**: Main terminal with cross-platform compatibility
- **vivid**: LS_COLORS themes (cyberdream, cyberdream-light)
- **alacritty**: Alternative terminal configuration — adjust `font.*.family` manually if you use it (setup does not drive Alacritty prompts)
- **k9s**: Kubernetes management tool configuration
- **vscode**: VS Code editor settings (manually updated when needed)
- **nvim**: Neovim editor configuration

### Personal Configuration (Not Synced)

Machine-specific details are stored in `~/.config/shell/personal.env`. If you chose **Nushell** during setup, `~/.config/shell/personal.nu` is also created.

**personal.env** holds:
- `IS_WORK` - Work vs personal machine flag
- `IS_MACOS` - macOS vs Linux detection
- `GITHUB_ORG` - Your GitHub organization (may be empty; **`gh_search --org`** / **`ghso`** requires it — set via setup or `export`)
- `GIT_EMAIL` - Your git commit email (may be empty; set a real address before committing; **`None`** in setup clears global **`user.email`**)
- `NAME` - Your full name

### Local Machine Configuration (Not Synced)

Machine-specific items are kept in `~/.zsh_local_rc`:
- Company-specific functions (e.g., dashboard shortcuts)
- Machine-specific aliases and paths
- Experimental configurations
- Temporary tools and shortcuts

Re-running **`./scripts/setup.sh`** does **not** overwrite **`~/.zsh_local_rc`** if it is already non-empty; delete or truncate the file first if you want the setup template re-created.

## Neovim IDE Cheatsheet

Quick reference for the keybindings/features wired up in `.config/nvim/` + `.config/wezterm/`:

### Pane / window navigation
- **Cmd+`** — toggle the bottom shell pane. Closed → opens + focuses. Open + focused → minimizes back to nvim. Open + unfocused → focuses (works from any pane).
- **Cmd+Shift+B** — same toggle for the right Claude pane.
- **Ctrl+H/J/K/L** — move focus between nvim splits (via smart-splits).
- **Cmd+Ctrl+H/J/K/L** — move focus between WezTerm panes.
- **Cmd+Alt+Arrow** — resize the focused pane (3 cells/press). Works in both nvim splits and WezTerm panes. **macOS Mission Control may capture Cmd+Alt+Arrow** — disable in *System Settings → Keyboard → Keyboard Shortcuts → Mission Control* if needed.

### Tabs / buffers
- **Cmd+1..9** — switch WezTerm tab.
- **`<leader>1..9`** — jump to nvim buffer slot (most-recent first).
- **Cmd+W** — in nvim editor, closes the current buffer (layout intact). In any other pane, closes the WezTerm tab.
- **Cmd+T** — new WezTerm tab; **Cmd+[ / Cmd+]** — prev/next tab.

### Editing
- **`<A-j>` / `<A-k>` (or `<A-Up>` / `<A-Down>`)** — move line/selection up/down (normal, insert, visual).
- **Ctrl+N** — add a cursor at the next match of the word under cursor (VS Code-style). **Ctrl+Up / Ctrl+Down** — vertical cursors. **Esc** clears extras. (`multicursor.nvim`)
- **`:q!`** — force close window, discard edits. **`:bd!`** — force delete buffer keeping layout. **`:e!`** — reload from disk, discarding edits. **`<leader>bd`** — close buffer (LazyVim default; prompts if unsaved).
- **`<leader>uf`** — toggle global autoformat. **`<leader>uF`** — toggle buffer autoformat. **`:LazyFormat`** — format on demand. (Format-on-save is enabled by default.)
- **`<leader>cp`** — Markdown browser preview (from LazyVim's `lang.markdown` extra). **`<leader>cd`** — show agent (Claude Code) diff via code-preview.nvim.
- **`<leader>mm`** — toggle the minimap (right side). **`<leader>ma`** — align multi-cursor columns.

### Git
- Inline blame shows at end-of-line after 300ms idle (gitsigns).
- **`<leader>gg`** — LazyGit. **`<leader>gf`** — LazyGit for the current file.
- **`<leader>ghs / ghr / ghp`** — stage / reset hunk / preview hunk (gitsigns).

## How It Works

### Shell Conditionals

The `.zshrc` uses standard shell conditionals based on environment variables:

```bash
# OS-specific configuration
if [[ "$IS_MACOS" == "true" ]]; then
    # macOS-specific paths and settings
    export PATH="/opt/homebrew/bin:$PATH"
else
    # Linux-specific configuration
    export PATH="/usr/local/bin:$PATH"
fi

# Work-specific configuration
if [[ "$IS_WORK" == "true" ]]; then
    # Work-specific settings
fi
```

### File Structure

```
~/dotfiles/
├── .zshrc                    # Main shell config with conditionals
├── .gitignore               # Excludes personal config files
├── scripts/
│   └── setup.sh            # Setup script for personal config
├── .config/
│   ├── git/config          # Git configuration
│   ├── nushell/            # Nushell config (config.nu, env.nu)
│   ├── starship/           # Starship prompt config
│   ├── wezterm/            # WezTerm terminal config
│   ├── alacritty/          # Alacritty terminal config
│   ├── Code/User/          # VS Code settings
│   ├── k9s/                # Kubernetes tool config
│   └── nvim/               # Neovim configuration
└── README.md               # This file

# Untracked files (created / managed locally)
~/.config/shell/personal.env   # Personal details (always)
~/.config/shell/personal.nu    # Nushell secrets mirror (only if you chose Nushell in setup)
~/.config/wezterm/local.lua    # Font + optional default_prog when setup chooses WezTerm as primary
~/.zsh_local_rc               # Machine-specific config
```

## Daily Usage

### Understanding Stow

Stow creates symlinks from your dotfiles directory to your home directory. When you edit a file in the dotfiles directory, the changes are immediately reflected in your home directory (and vice versa).

```bash
# Check what stow would do (dry run)
stow --simulate .

# Create symlinks for all configurations
stow .

# Remove all symlinks (if needed)
stow --delete .

# Re-create all symlinks (useful after adding new files)
stow --restow .
```

### Editing Configurations

```bash
# Edit synced configurations (two ways - both work the same)
cd ~/dotfiles

# Method 1: Edit in dotfiles directory
vim .zshrc                   # Edit shell config
vim .config/git/config      # Edit git config

# Method 2: Edit via symlinks (same result)
vim ~/.zshrc                 # This edits ~/dotfiles/.zshrc
vim ~/.config/git/config     # This edits ~/dotfiles/.config/git/config

# Changes are immediately active (no stow command needed)
source ~/.zshrc             # Reload shell config if needed
```

### Step-by-Step: Adding a New Alias

Let's add a new alias `ll` for `ls -la`:

1. **Edit the zshrc file**:
   ```bash
   cd ~/dotfiles
   vim .zshrc
   ```

2. **Add the alias** in the "General Aliases" section:
   ```bash
   # =========================
   # General Aliases
   # =========================
   alias ls='ls --color'
   alias ll='ls -la'          # <-- Add this line
   alias vim='nvim'
   alias c='clear'
   ```

3. **Save and test**:
   ```bash
   source ~/.zshrc            # Reload shell config
   ll                         # Test the new alias
   ```

4. **Commit the change**:
   ```bash
   git add .zshrc
   git commit -m "Add ll alias for ls -la"
   git push
   ```

### Step-by-Step: Adding a New Application Configuration

Let's add configuration for a new app called `myapp`:

1. **Create the app's config** (if it doesn't exist):
   ```bash
   mkdir -p ~/.config/myapp
   echo 'setting: value' > ~/.config/myapp/config.yaml
   ```

2. **Add it to dotfiles**:
   ```bash
   cd ~/dotfiles
   mkdir -p .config/myapp
   cp ~/.config/myapp/config.yaml .config/myapp/config.yaml
   ```

3. **Remove the original and stow**:
   ```bash
   rm ~/.config/myapp/config.yaml
   stow .                     # This creates the symlink
   ```

4. **Verify the symlink**:
   ```bash
   ls -la ~/.config/myapp/config.yaml
   # Should show: ~/.config/myapp/config.yaml -> ../../dotfiles/.config/myapp/config.yaml
   ```

5. **Test and commit**:
   ```bash
   # Test that the app still works with the symlinked config
   git add .config/myapp/
   git commit -m "Add myapp configuration"
   git push
   ```

### Adding Machine-Specific Items

```bash
# Edit local machine config (not synced)
vim ~/.zsh_local_rc

# Add company-specific functions, local aliases, etc.
# Example:
# alias work-project='cd ~/work/current-project && code .'
# export LOCAL_DEV_URL="http://localhost:3000"
```

### Updating VS Code Settings

```bash
# When you change VS Code settings and want to sync them:
cd ~/dotfiles
cp ~/.config/Code/User/settings.json .config/Code/User/settings.json

# Check what changed
git diff .config/Code/User/settings.json

# Commit the changes
git add .config/Code/User/settings.json
git commit -m "Update VS Code: add new formatter settings"
git push
```

### Syncing Changes Across Machines

```bash
# On machine where you made changes
cd ~/dotfiles
git add .
git commit -m "Update configurations"
git push

# On other machines
cd ~/dotfiles
git pull
# No need to re-stow - symlinks automatically reflect changes
source ~/.zshrc            # Only if you changed shell config
```

### Managing Stow Conflicts

If stow encounters existing files, it will warn you:

```bash
# If you get conflicts when stowing
stow .
# WARNING! stowing . would cause conflicts:
#   * existing target is not owned by stow: .zshrc

# Options to resolve:
# 1. Backup and remove the existing file
mv ~/.zshrc ~/.zshrc.backup
stow .

# 2. Use stow --adopt to take ownership of existing files
stow --adopt .              # Moves existing files into dotfiles directory
git diff                    # Check what changed
git checkout .              # Restore your dotfiles version (if needed)
```

## Setting Up New Machines

1. **Clone repository**: `git clone https://github.com/jordan-pierre/dotfiles.git ~/dotfiles`
2. **Run setup**: `cd ~/dotfiles && ./scripts/setup.sh`
3. **Apply configurations**: `stow .`
4. **Restart terminal** or `source ~/.zshrc`

The setup script will:
- Detect your OS (macOS/Linux)
- Prompt for machine type (work/personal) and identity (name, **GitHub org**, **git email**). **GitHub org** defaults from **`GITHUB_ORG`** in your environment, then from **`~/.config/shell/personal.env`** if unset; the prompt shows **`[YourOrg]`** or **`[None]`**. Press **Enter** to keep the current value; type **`None`** (any case) to clear it. **Git email** uses the same pattern: **`GIT_EMAIL`**, then **`git config --global user.email`**, then **`personal.env`**; **`[None]`** / **`None`** clear and remove global **`user.email`**.
- Ask for **interactive shell**: **zsh only** (default) or **Nushell** (adds `personal.nu`, nushell dirs, **carapace**, **nushell** install — **zsh** is still fully configured)
- Optionally install **vivid**, **fzf**, and related tools (macOS: Homebrew; Linux: **dnf/apt** with mapped package names). **Enter** accepts the default (**yes**).
- Let you pick a **Nerd Font** (branch/Python icons in Starship need it); macOS installs font **casks** when possible
- Ask for **primary terminal**: **WezTerm** (default; installs WezTerm if missing; writes **`~/.config/wezterm/local.lua`** for font + optional **`nu`**) vs **Other / OS Default** (echo-only font hints; no `local.lua`; on macOS use Terminal.app or another terminal and set the font yourself)
- Install **stow**, **starship**, **zoxide** (always); **`carapace`** / **`nu`** only if Nushell was chosen
- Generate **`~/.config/shell/personal.env`**, optionally **`personal.nu`**, and **`~/.zsh_local_rc`** only when that file is **missing or empty** (reruns **preserve** a non-empty **`~/.zsh_local_rc`**), configure **git**, and print **post-setup** notes (icons, fonts, `stow .`)

### Git SSH commit signing

`.config/git/config` enables SSH commit + tag signing using your `~/.ssh/id_ed25519.pub` key and trusts entries in `.config/git/allowed_signers`. On a fresh machine:

1. Make sure `~/.ssh/id_ed25519` exists (`ssh-keygen -t ed25519 -C "you@example.com"` if not). Edit `.config/git/allowed_signers` to include your `<email> ssh-ed25519 <pubkey> <comment>` line.
2. Run `stow .` so `~/.config/git/config` and `~/.config/git/allowed_signers` link into place.
3. Add the **same public key** at *GitHub → Settings → SSH and GPG keys → New SSH key* with **Key type: Signing Key** (separate from the auth key entry).
4. Verify: `git commit --allow-empty -m "test"` then `git log --show-signature -1` should print `Good "git" signature`.

### Upgrading from older personal.env

If you have `export AWS_PROFILE=""` in `~/.config/shell/personal.env`, **remove that line** — it sets the variable to an empty string in every new shell. The dotfiles no longer manage `AWS_PROFILE`.

## Customization

### Adding New Configurations

```bash
# Add a new config file to dotfiles
cp ~/.config/newapp/config.yml ~/dotfiles/.config/newapp/config.yml

# If it needs environment-specific logic, add conditionals to the file
# or reference environment variables from personal.env

# Stow the new configuration
cd ~/dotfiles
stow .
```

### Environment Variables

Available in shell configurations (sourced from `~/.config/shell/personal.env`):

- `$IS_WORK` - "true" for work machines, "false" for personal
- `$IS_MACOS` - "true" on macOS, "false" on Linux  
- `$GITHUB_ORG` - Your GitHub organization (may be empty; **`gh_search --org`** needs it set)
- `$GIT_EMAIL` - Your git commit email (may be empty)
- `$NAME` - Your full name

### Shell Conditional Examples

```bash
# Platform-specific
if [[ "$IS_MACOS" == "true" ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color'
fi

# Work-specific
if [[ "$IS_WORK" == "true" ]]; then
    export WORK_SPECIFIC_VAR="value"
fi

# Conditional based on installed tools
if command -v docker &> /dev/null; then
    alias d='docker'
fi
```

## Security

### Excluded Files

The following files are automatically excluded from git:
- `~/.config/shell/personal.env` - Personal details and machine type
- `~/.config/shell/personal.nu` - Nushell personal vars (when used)
- `~/.zsh_local_rc` - Machine-specific configurations
- OS-specific files (`.DS_Store`, etc.)
- Cache and temporary files

### Personal Information

- **Never committed**: Personal details stay in untracked files
- **Machine-specific**: Each machine has its own personal.env
- **Secure**: No sensitive information in the repository

## Troubleshooting

### Setup Issues

```bash
# Re-run setup if needed (safe for fonts/WezTerm; preserves non-empty ~/.zsh_local_rc)
./scripts/setup.sh

# Check if personal config exists
cat ~/.config/shell/personal.env

# Verify stow installation
which stow
```

### Configuration Issues

```bash
# Check what stow would do
stow --simulate .

# Re-stow everything
stow --restow .

# Check for conflicts
stow --verbose .
```

### Shell Issues

```bash
# Check if personal config is loaded
echo $IS_WORK $IS_MACOS $GITHUB_ORG

# Reload shell configuration
source ~/.zshrc

# Check for syntax errors
zsh -n ~/.zshrc
```

## Migration from Other Systems

### From Chezmoi

If migrating from chezmoi, the setup script will help you configure the equivalent environment variables and conditionals.

### From Other Stow Setups

This setup is compatible with existing stow workflows. Simply run the setup script to generate the personal configuration files.

## Contributing

When adding new configurations:

1. Test on both macOS and Linux if possible
2. Use shell conditionals for platform-specific differences
3. Keep personal details in environment variables
4. Update this README if adding new features

## License

This configuration is personal but feel free to use it as inspiration for your own dotfiles setup.
