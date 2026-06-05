#!/bin/bash
# Dotfiles Setup Script
# Generates machine-specific configuration and sets up stow-based dotfiles

set -e

echo "🚀 Setting up dotfiles with stow..."
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    IS_MACOS="true"
else
    OS="linux"
    IS_MACOS="false"
fi

echo "🖥️  Detected OS: $OS"
echo ""

# -----------------------------------------------------------------------------
# Prompt for machine type
# -----------------------------------------------------------------------------
echo "🏷️  What type of machine is this?"
echo "1) Work machine"
echo "2) Personal machine"
echo ""
while true; do
    read -r -p "Enter choice (1-2): " machine_choice
    case $machine_choice in
        1)
            MACHINE_TYPE="work"
            IS_WORK="true"
            break
            ;;
        2)
            MACHINE_TYPE="personal"
            IS_WORK="false"
            break
            ;;
        *)
            echo "❌ Invalid choice — enter 1 or 2."
            ;;
    esac
done

echo ""
echo "📝 Enter configuration details:"
read -r -p "Your full name [Jordan Pierre]: " NAME
NAME=${NAME:-"Jordan Pierre"}

# GitHub org: env first, then existing personal.env; [None] when unset; Enter keeps; "None" clears
DEFAULT_GITHUB_ORG="${GITHUB_ORG:-}"
if [[ -z "$DEFAULT_GITHUB_ORG" ]] && [[ -f "$HOME/.config/shell/personal.env" ]]; then
    while IFS= read -r __line || [[ -n "$__line" ]]; do
        [[ "$__line" =~ ^export[[:space:]]+GITHUB_ORG=(.*)$ ]] || continue
        __val="${BASH_REMATCH[1]}"
        __val="${__val#\"}"
        __val="${__val%\"}"
        __val="${__val#\'}"
        __val="${__val%\'}"
        DEFAULT_GITHUB_ORG="$__val"
        break
    done < "$HOME/.config/shell/personal.env"
fi
if [[ -n "$DEFAULT_GITHUB_ORG" ]]; then
    _gh_org_suffix=" [$DEFAULT_GITHUB_ORG]"
else
    _gh_org_suffix=" [None]"
fi
read -r -p "GitHub organization${_gh_org_suffix}: " GITHUB_ORG_INPUT
GITHUB_ORG_INPUT=$(printf '%s' "$GITHUB_ORG_INPUT" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
_github_org_input_lc=$(printf '%s' "$GITHUB_ORG_INPUT" | tr '[:upper:]' '[:lower:]')
if [[ -z "$GITHUB_ORG_INPUT" ]]; then
    GITHUB_ORG="$DEFAULT_GITHUB_ORG"
elif [[ "$_github_org_input_lc" == "none" ]]; then
    GITHUB_ORG=""
else
    GITHUB_ORG="$GITHUB_ORG_INPUT"
fi
unset _gh_org_suffix _github_org_input_lc __line __val

# Git email: env, then git global config, then personal.env; [None] when unset; Enter keeps; "None" clears
DEFAULT_GIT_EMAIL="${GIT_EMAIL:-}"
if [[ -z "$DEFAULT_GIT_EMAIL" ]]; then
    DEFAULT_GIT_EMAIL="$(git config --global user.email 2>/dev/null || true)"
fi
if [[ -z "$DEFAULT_GIT_EMAIL" ]] && [[ -f "$HOME/.config/shell/personal.env" ]]; then
    while IFS= read -r __line || [[ -n "$__line" ]]; do
        [[ "$__line" =~ ^export[[:space:]]+GIT_EMAIL=(.*)$ ]] || continue
        __val="${BASH_REMATCH[1]}"
        __val="${__val#\"}"
        __val="${__val%\"}"
        __val="${__val#\'}"
        __val="${__val%\'}"
        DEFAULT_GIT_EMAIL="$__val"
        break
    done < "$HOME/.config/shell/personal.env"
fi
if [[ -n "$DEFAULT_GIT_EMAIL" ]]; then
    _git_email_suffix=" [$DEFAULT_GIT_EMAIL]"
else
    _git_email_suffix=" [None]"
fi
read -r -p "Git email${_git_email_suffix}: " GIT_EMAIL_INPUT
GIT_EMAIL_INPUT=$(printf '%s' "$GIT_EMAIL_INPUT" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
_git_email_input_lc=$(printf '%s' "$GIT_EMAIL_INPUT" | tr '[:upper:]' '[:lower:]')
if [[ -z "$GIT_EMAIL_INPUT" ]]; then
    GIT_EMAIL="$DEFAULT_GIT_EMAIL"
elif [[ "$_git_email_input_lc" == "none" ]]; then
    GIT_EMAIL=""
else
    GIT_EMAIL="$GIT_EMAIL_INPUT"
fi
unset _git_email_suffix _git_email_input_lc __line __val

# -----------------------------------------------------------------------------
# Interactive shell: default zsh; Nushell adds nu on top
# -----------------------------------------------------------------------------
echo ""
echo "💻 Interactive shell"
echo "   zsh is always configured. Choose whether to also set up Nushell."
echo "1) Zsh only — no Nushell config [default]"
echo "2) Nushell — also personal.nu, carapace, nushell paths (use with WezTerm to launch nu)"
echo ""
while true; do
    read -r -p "Enter choice (1-2) [1]: " shell_choice
    shell_choice=${shell_choice:-1}
    case "$shell_choice" in
        1|2)
            break
            ;;
        *)
            echo "❌ Invalid choice — enter 1 or 2."
            ;;
    esac
done

USE_NUSHELL=false
if [[ "$shell_choice" == "2" ]]; then
    USE_NUSHELL=true
fi

# -----------------------------------------------------------------------------
# Recommended CLI tools
# -----------------------------------------------------------------------------
echo ""
read -r -p "Install recommended CLI tools (vivid, fzf, etc.)? [Y/n]: " install_cli_tools
install_cli_tools_lc=$(printf '%s' "${install_cli_tools:-Y}" | tr '[:upper:]' '[:lower:]')
case "$install_cli_tools_lc" in
    y|yes)
        INSTALL_CLI_TOOLS=true
        ;;
    *)
        INSTALL_CLI_TOOLS=false
        ;;
esac

# -----------------------------------------------------------------------------
# Nerd Font menu (default first, alphabetical, Other last)
# -----------------------------------------------------------------------------
echo ""
echo "🔤 Nerd Font — Starship git branch + Python icons need Nerd Font / PUA glyphs."
echo " 1) JetBrains Mono Nerd Font [default]"
echo " 2) 0xProto Nerd Font"
echo " 3) Cousine Nerd Font"
echo " 4) FiraCode Nerd Font"
echo " 5) Hack Nerd Font"
echo " 6) Other — supply packages / WezTerm font name yourself"
echo ""
while true; do
    read -r -p "Enter choice (1-6) [1]: " font_choice
    font_choice=${font_choice:-1}

    FONT_BREW_CASK=""
    FONT_LINUX_PKG=""
    FONT_WEZTERM_NAME=""
    FONT_LINUX_HINT=""

    case $font_choice in
        1)
            FONT_BREW_CASK="font-jetbrains-mono-nerd-font"
            FONT_WEZTERM_NAME="JetBrainsMono Nerd Font"
            FONT_LINUX_HINT="Install a JetBrains Mono Nerd Font package from your distro, Copr, or https://www.nerdfonts.com/"
            break
            ;;
        2)
            FONT_BREW_CASK="font-0xproto-nerd-font"
            FONT_WEZTERM_NAME="0xProto Nerd Font"
            FONT_LINUX_HINT="Install 0xProto Nerd Font from nerd-fonts releases or your distro."
            break
            ;;
        3)
            FONT_BREW_CASK="font-cousine-nerd-font"
            FONT_WEZTERM_NAME="Cousine Nerd Font"
            FONT_LINUX_HINT="Install Cousine Nerd Font from nerd-fonts or distro packages."
            break
            ;;
        4)
            FONT_BREW_CASK="font-fira-code-nerd-font"
            FONT_WEZTERM_NAME="FiraCode Nerd Font"
            FONT_LINUX_HINT="Install Fira Code Nerd Font from nerd-fonts or distro packages."
            break
            ;;
        5)
            FONT_BREW_CASK="font-hack-nerd-font"
            FONT_WEZTERM_NAME="Hack Nerd Font"
            FONT_LINUX_HINT="Install Hack Nerd Font from nerd-fonts or distro packages."
            break
            ;;
        6)
            echo ""
            if [[ "$OS" == "macos" ]]; then
                read -r -p "Homebrew font cask name (e.g. font-foo-nerd-font), or empty to skip brew: " FONT_BREW_CASK
            else
                read -r -p "Distro font package name for dnf/apt, or empty for manual install only: " FONT_LINUX_PKG
                FONT_LINUX_PKG=${FONT_LINUX_PKG:-}
            fi
            read -r -p "Exact WezTerm font family string (see 'wezterm ls-fonts' / fc-list): " FONT_WEZTERM_NAME
            if [[ -z "$FONT_WEZTERM_NAME" ]]; then
                FONT_WEZTERM_NAME="JetBrainsMono Nerd Font"
                echo "   (defaulting WezTerm font to JetBrainsMono Nerd Font)"
            fi
            break
            ;;
        *)
            echo "❌ Invalid choice — enter 1-6."
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Primary terminal
# -----------------------------------------------------------------------------
echo ""
if [[ "$OS" == "macos" ]]; then
    echo "🖼️  Primary terminal (WezTerm gets ~/.config/wezterm/local.lua for font + optional nu)."
else
    echo "🖼️  Primary terminal"
fi
echo "1) WezTerm [default]"
echo "2) Other / OS Default"
echo ""
while true; do
    read -r -p "Enter choice (1-2) [1]: " term_choice
    term_choice=${term_choice:-1}
    case "$term_choice" in
        1|2)
            break
            ;;
        *)
            echo "❌ Invalid choice — enter 1 or 2."
            ;;
    esac
done

USE_WEZTERM=false
if [[ "$term_choice" == "1" ]]; then
    USE_WEZTERM=true
fi

echo ""
echo "🔧 Configuring for $MACHINE_TYPE machine on $OS..."

mkdir -p ~/.config/shell

# -----------------------------------------------------------------------------
# Personal env (always)
# -----------------------------------------------------------------------------
cat > ~/.config/shell/personal.env << EOF
# Personal configuration - DO NOT COMMIT
# Generated by dotfiles setup script on $(date)

export IS_WORK="$IS_WORK"
export IS_MACOS="$IS_MACOS"
export GITHUB_ORG="$GITHUB_ORG"
export GIT_EMAIL="$GIT_EMAIL"
export NAME="$NAME"
EOF

echo "✅ Personal config created at ~/.config/shell/personal.env"

# -----------------------------------------------------------------------------
# Nushell-specific files
# -----------------------------------------------------------------------------
if [[ "$USE_NUSHELL" == "true" ]]; then
    cat > ~/.config/shell/personal.nu << EOF
# Personal configuration - DO NOT COMMIT
# Generated by dotfiles setup script on $(date)

\$env.IS_WORK = "$IS_WORK"
\$env.GITHUB_ORG = "$GITHUB_ORG"
\$env.GIT_EMAIL = "$GIT_EMAIL"
\$env.NAME = "$NAME"
EOF
    echo "✅ Nushell config created at ~/.config/shell/personal.nu"

    mkdir -p ~/.config/nushell/autoload
    if [[ "$OS" == "macos" ]]; then
        mkdir -p ~/Library/Caches/nushell
    else
        mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/nushell"
    fi
else
    echo "ℹ️  Skipping personal.nu and nushell dirs (zsh-only)."
fi

# -----------------------------------------------------------------------------
# Local zsh rc template (do not wipe non-empty user file on rerun)
# -----------------------------------------------------------------------------
if [[ -s "$HOME/.zsh_local_rc" ]]; then
    echo "ℹ️  Keeping existing ~/.zsh_local_rc (non-empty)."
else
    cat > ~/.zsh_local_rc << 'EOF'
# Local machine-specific configuration
# This file is not synced and can contain:
# - Machine-specific apps and tools
# - Company/work-specific items
# - Experimental configurations
# - Local development shortcuts

# Example: Company dashboard function
# ob() {
#     open "https://your-company-dashboard.com/"
# }

# Example: Machine-specific aliases
# alias projects='cd /path/to/your/projects'

# Add your local configurations below:

EOF
    echo "✅ Local config created at ~/.zsh_local_rc"
fi

# -----------------------------------------------------------------------------
# Git
# -----------------------------------------------------------------------------
echo "🔧 Configuring git..."
git config --global user.name "$NAME"
if [[ -n "$GIT_EMAIL" ]]; then
    git config --global user.email "$GIT_EMAIL"
else
    git config --global --unset-all user.email 2>/dev/null || true
fi

# -----------------------------------------------------------------------------
# Package helpers (brew macOS only; Linux uses dnf/apt with mapped names)
# -----------------------------------------------------------------------------
install_linux_packages() {
    local rpm_pkg=$1
    local deb_pkg=$2
    if command -v dnf &> /dev/null; then
        sudo dnf install -y "$rpm_pkg" || return 1
        return 0
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update -qq || true
        sudo apt-get install -y "$deb_pkg" || return 1
        return 0
    else
        return 1
    fi
}

ensure_binary_macos_brew() {
    local exe=$1
    local formula=$2
    local label=${3:-$formula}
    if command -v "$exe" &> /dev/null; then
        return 0
    fi
    echo "📦 Installing $label..."
    if command -v brew &> /dev/null; then
        brew install "$formula" || return 1
    else
        echo "⚠️  Homebrew not found. Install $label manually (brew install $formula)."
        return 1
    fi
}

ensure_binary_linux_mapped() {
    local exe=$1
    local rpm_pkg=$2
    local deb_pkg=$3
    local label=${4:-$exe}
    if command -v "$exe" &> /dev/null; then
        return 0
    fi
    echo "📦 Installing $label ($rpm_pkg / $deb_pkg)..."
    if install_linux_packages "$rpm_pkg" "$deb_pkg"; then
        return 0
    fi
    echo "⚠️  Could not install $label via dnf/apt. Install manually."
    return 1
}

ensure_binary() {
    local exe=$1
    local brew_formula=$2
    local rpm_pkg=$3
    local deb_pkg=$4
    local label=${5:-$exe}
    if command -v "$exe" &> /dev/null; then
        return 0
    fi
    if [[ "$OS" == "macos" ]]; then
        ensure_binary_macos_brew "$exe" "$brew_formula" "$label" || true
    else
        ensure_binary_linux_mapped "$exe" "$rpm_pkg" "$deb_pkg" "$label" || true
    fi
}

install_stow_if_needed() {
    if command -v stow &> /dev/null; then
        return 0
    fi
    echo "📦 Installing stow..."
    if [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install stow
        else
            echo "❌ Homebrew not found. Install stow manually: brew install stow"
            exit 1
        fi
    else
        if command -v dnf &> /dev/null; then
            sudo dnf install -y stow
        elif command -v apt-get &> /dev/null; then
            sudo apt-get update -qq && sudo apt-get install -y stow
        else
            echo "❌ Could not install stow. Install manually."
            exit 1
        fi
    fi
}

install_stow_if_needed

# Starship / zoxide (always)
ensure_binary starship starship starship starship "starship" || {
    echo "⚠️  Starship missing: https://starship.rs/guide/"
}
ensure_binary zoxide zoxide zoxide zoxide "zoxide" || {
    echo "⚠️  Zoxide missing: https://github.com/ajeetdsouza/zoxide"
}

# Carapace + nu only with Nushell
if [[ "$USE_NUSHELL" == "true" ]]; then
    ensure_binary carapace carapace carapace carapace-bin "carapace" || {
        echo "⚠️  Carapace missing: https://carapace-sh.github.io/carapace-bin/install.html"
    }
    ensure_binary nu nushell nushell nushell "nushell" || {
        echo "⚠️  Nushell missing: https://www.nushell.sh/book/installation.html"
    }
fi

# Optional CLI stack
if [[ "$INSTALL_CLI_TOOLS" == "true" ]]; then
    ensure_binary vivid vivid vivid vivid "vivid" || true
    ensure_binary fzf fzf fzf fzf "fzf" || true
    # thefuck: Debian/Ubuntu package name differs
    if command -v thefuck &> /dev/null; then
        :
    elif [[ "$OS" == "macos" ]]; then
        ensure_binary_macos_brew thefuck thefuck "thefuck" || true
    else
        ensure_binary_linux_mapped thefuck python3-thefuck python3-thefuck "thefuck" || {
            echo "⚠️  thefuck: try pipx install thefuck or see https://github.com/nvbn/thefuck"
        }
    fi
fi

# -----------------------------------------------------------------------------
# Nerd Font install (macOS cask; Linux hints only)
# -----------------------------------------------------------------------------
if [[ "$font_choice" != "6" ]] || [[ -n "$FONT_BREW_CASK" ]] || [[ -n "${FONT_LINUX_PKG:-}" ]]; then
    if [[ "$OS" == "macos" ]] && [[ -n "$FONT_BREW_CASK" ]]; then
        if command -v brew &> /dev/null; then
            echo "📦 Installing font cask $FONT_BREW_CASK..."
            brew install --cask "$FONT_BREW_CASK" || echo "⚠️  Font cask install failed; install manually."
        else
            echo "⚠️  Homebrew not found — install Nerd Font manually for Starship icons."
        fi
    elif [[ "$OS" == "linux" ]]; then
        if [[ -n "${FONT_LINUX_PKG:-}" ]]; then
            echo "📦 Installing Linux font package ${FONT_LINUX_PKG}..."
            if command -v dnf &> /dev/null; then
                sudo dnf install -y "${FONT_LINUX_PKG}" || echo "⚠️  dnf install font failed."
            elif command -v apt-get &> /dev/null; then
                sudo apt-get update -qq && sudo apt-get install -y "${FONT_LINUX_PKG}" || echo "⚠️  apt install font failed."
            fi
        elif [[ -n "$FONT_LINUX_HINT" ]]; then
            echo "ℹ️  Linux font: $FONT_LINUX_HINT"
        fi
    fi
fi

# -----------------------------------------------------------------------------
# WezTerm install when selected
# -----------------------------------------------------------------------------
wezterm_present() {
    command -v wezterm &> /dev/null && return 0
    if [[ "$OS" == "macos" ]] && [[ -d "/Applications/WezTerm.app" ]]; then
        return 0
    fi
    return 1
}

if [[ "$USE_WEZTERM" == "true" ]]; then
    if ! wezterm_present; then
        echo "📦 Installing WezTerm..."
        if [[ "$OS" == "macos" ]]; then
            if command -v brew &> /dev/null; then
                brew install --cask wezterm || echo "⚠️  brew install --cask wezterm failed."
            else
                echo "⚠️  Install WezTerm manually: https://wezfurlong.org/wezterm/installation.html"
            fi
        else
            if install_linux_packages wezterm wezterm; then
                :
            else
                echo "⚠️  WezTerm not in default repos — try Flatpak, Copr, or https://wezfurlong.org/wezterm/install/linux.html"
            fi
        fi
    fi
fi

# -----------------------------------------------------------------------------
# ~/.config/wezterm/local.lua (only when WezTerm selected)
# -----------------------------------------------------------------------------
escape_lua_string() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

write_wezterm_local_lua() {
    local font_name=$1
    local nu_path=$2
    mkdir -p ~/.config/wezterm
    local out=~/.config/wezterm/local.lua
    local font_esc
    font_esc=$(escape_lua_string "$font_name")
    if [[ -n "$nu_path" ]]; then
        local nu_esc
        nu_esc=$(escape_lua_string "$nu_path")
        cat > "$out" << EOF
-- Generated by dotfiles setup.sh — font + default_prog (nushell)
local wezterm = require("wezterm")
return {
  font = wezterm.font("$font_esc", { weight = "Bold" }),
  font_size = 15,
  window_frame = { font = wezterm.font("$font_esc", { weight = "Bold" }) },
  default_prog = { "$nu_esc" },
}
EOF
    else
        cat > "$out" << EOF
-- Generated by dotfiles setup.sh — font only (shell stays repo default, usually zsh)
local wezterm = require("wezterm")
return {
  font = wezterm.font("$font_esc", { weight = "Bold" }),
  font_size = 15,
  window_frame = { font = wezterm.font("$font_esc", { weight = "Bold" }) },
}
EOF
    fi
    echo "✅ WezTerm overrides written to ~/.config/wezterm/local.lua"
}

resolve_nu_binary() {
    command -v nu 2>/dev/null || true
}

if [[ "$USE_WEZTERM" == "true" ]]; then
    NU_FOR_WEZ=""
    if [[ "$USE_NUSHELL" == "true" ]]; then
        NU_FOR_WEZ=$(resolve_nu_binary)
        if [[ -z "$NU_FOR_WEZ" ]]; then
            if [[ "$OS" == "macos" ]]; then
                for cand in /opt/homebrew/bin/nu /usr/local/bin/nu; do
                    if [[ -x "$cand" ]]; then
                        NU_FOR_WEZ=$cand
                        break
                    fi
                done
            else
                for cand in /usr/bin/nu "$HOME/.cargo/bin/nu"; do
                    if [[ -x "$cand" ]]; then
                        NU_FOR_WEZ=$cand
                        break
                    fi
                done
            fi
        fi
        if [[ -z "$NU_FOR_WEZ" ]]; then
            NU_FOR_WEZ="nu"
            echo "⚠️  'nu' not on PATH yet — local.lua uses { \"nu\" }; install nushell or fix PATH."
        fi
    fi
    write_wezterm_local_lua "$FONT_WEZTERM_NAME" "${NU_FOR_WEZ:-}"
else
    rm -f ~/.config/wezterm/local.lua
    echo "ℹ️  Primary terminal is not WezTerm — ~/.config/wezterm/local.lua omitted (removed if it existed)."
fi

# -----------------------------------------------------------------------------
# Completion banner
# -----------------------------------------------------------------------------
echo ""
echo "🎉 Setup complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Starship: git branch + Python segments use Nerd Font icons (PUA glyphs)."
echo " Set your terminal profile font to: $FONT_WEZTERM_NAME"
echo " or icons may show as boxes. (fc-list / Font Book / wezterm ls-fonts)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ "$USE_WEZTERM" == "true" ]]; then
    echo ""
    echo " WezTerm: restart WezTerm after 'stow .' so config + local.lua load."
    if [[ "$USE_NUSHELL" == "true" ]]; then
        echo " Interactive shell: Nushell via default_prog (zsh configs remain; type zsh anytime)."
    else
        echo " Interactive shell: repo default (zsh) unless you changed wezterm.lua."
    fi
else
    echo ""
    if [[ "$OS" == "macos" ]]; then
        echo " Terminal.app: Settings → Profiles → Text → Font → pick your Nerd Font."
    else
        echo " Your terminal: set profile font to the Nerd Font matching: $FONT_WEZTERM_NAME"
    fi
    if [[ "$USE_NUSHELL" == "true" ]]; then
        echo " Nushell: set your terminal's startup command to 'nu', or run nu manually (no local.lua)."
    fi
fi

echo ""
echo " Alacritty users: edit ~/.config/alacritty/alacritty.toml font.family after stow to match."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "1. Review ~/.zsh_local_rc for machine-specific configurations"
echo "2. Run 'stow .' from this dotfiles directory to create symlinks"
if [[ "$USE_WEZTERM" == "true" ]]; then
    echo "3. Open WezTerm"
else
    echo "3. Open your terminal and confirm Nerd Font + tools"
fi
echo ""
echo "📝 Machine-specific items:"
echo "   zsh:     ~/.zsh_local_rc"
if [[ "$USE_NUSHELL" == "true" ]]; then
    echo "   nushell: ~/.config/nushell/autoload/"
fi
echo "🔧 Edit synced configs in this dotfiles directory"
