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

```bash
# Clone the repository
git clone https://github.com/jordan-pierre/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run setup script (detects OS, prompts for details, installs stow)
./scripts/setup.sh

# Create symlinks
stow .
```

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
- **starship**: Modern shell prompt configuration
- **git**: Version control settings (user details set by setup script)
- **wezterm**: Main terminal with cross-platform compatibility
- **alacritty**: Alternative terminal configuration (fallback option)
- **k9s**: Kubernetes management tool configuration
- **vscode**: VS Code editor settings (manually updated when needed)
- **nvim**: Neovim editor configuration

### Personal Configuration (Not Synced)

Machine-specific details are stored in `~/.config/shell/personal.env`:
- `IS_WORK` - Work vs personal machine flag
- `IS_MACOS` - macOS vs Linux detection
- `GITHUB_ORG` - Your GitHub organization
- `GIT_EMAIL` - Your git commit email
- `AWS_PROFILE` - Your AWS default profile
- `NAME` - Your full name

### Local Machine Configuration (Not Synced)

Machine-specific items are kept in `~/.zsh_local_rc`:
- Company-specific functions (e.g., dashboard shortcuts)
- Machine-specific aliases and paths
- Experimental configurations
- Temporary tools and shortcuts

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

# AWS profile (if set)
if [[ -n "$AWS_PROFILE" ]]; then
    export AWS_DEFAULT_PROFILE="$AWS_PROFILE"
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
│   ├── starship/           # Starship prompt config
│   ├── wezterm/            # WezTerm terminal config
│   ├── alacritty/          # Alacritty terminal config
│   ├── Code/User/          # VS Code settings
│   ├── k9s/                # Kubernetes tool config
│   └── nvim/               # Neovim configuration
└── README.md               # This file

# Untracked files (created by setup script)
~/.config/shell/personal.env  # Personal details
~/.zsh_local_rc              # Machine-specific config
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
- Install stow if not present
- Prompt for machine type (work/personal)
- Ask for your GitHub org, git email, and AWS profile
- Generate `~/.config/shell/personal.env` with your details
- Create `~/.zsh_local_rc` for machine-specific items
- Configure git with your name and email

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
- `$GITHUB_ORG` - Your GitHub organization
- `$GIT_EMAIL` - Your git commit email
- `$AWS_PROFILE` - Your AWS default profile (if set)
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
# Re-run setup if needed
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
