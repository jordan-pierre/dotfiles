# =========================
# Load Personal Configuration
# =========================
# Source personal config (untracked file with machine-specific details)
[[ -f ~/.config/shell/personal.env ]] && source ~/.config/shell/personal.env

# =========================
# Zinit bootstrap
# =========================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# =========================
# Plugins via Zinit
# =========================
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Oh My Zsh snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# =========================
# Keybindings & vi mode
# =========================
bindkey -e
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward
bindkey '^[w' kill-region
bindkey -v  # vi mode enabled (Starship shows ❮ in NORMAL)

# =========================
# History
# =========================
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory
setopt hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# Make Backspace reliable across keymaps
if [[ -t 1 ]]; then stty erase '^?'; fi
for km in emacs viins vicmd; do
  bindkey -M $km '^?' backward-delete-char
  bindkey -M $km '^H' backward-delete-char
done

# =========================
# Completion & fzf-tab styling
# =========================
fpath=("$HOME/.zsh/completions" $fpath)
fpath=(/Users/jordan.pierre/.docker/completions $fpath)
fpath+=~/.zfunc

autoload -Uz compinit bashcompinit add-zsh-hook
compinit
bashcompinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# =========================
# Shell integrations
# =========================
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# =========================
# uv tooling
# =========================
export VIRTUAL_ENV_DISABLE_PROMPT=1   # activators never change the prompt
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

# =========================
# Paths & Environment Variables
# =========================
if [[ "$IS_MACOS" == "true" ]]; then
    # macOS-specific paths and environment
    export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
    PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"
    export WEZTERM_SHELL_SKIP_ALL=1
    export PATH="$PATH:~/.lmstudio/bin"
else
    # Linux-specific paths
    export PATH="/usr/local/bin:$PATH"
fi

if [[ -n "$AWS_PROFILE" ]]; then
    # AWS configuration
    export AWS_DEFAULT_PROFILE="$AWS_PROFILE"
fi

export PATH

# =========================
# Platform-specific completions
# =========================
# Terraform completion (only if terraform is installed)
if [[ "$IS_MACOS" == "true" ]]; then
    [[ $commands[terraform] ]] && complete -o nospace -C /opt/homebrew/bin/terraform terraform
else
    [[ $commands[terraform] ]] && complete -o nospace -C terraform terraform
fi

# =========================
# General Aliases
# =========================
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias k='kubectl'
alias uvr='uv run'
eval $(thefuck --alias fak)

# =========================
# macOS-specific Aliases & Functions
# =========================
if [[ "$IS_MACOS" == "true" ]]; then
    # Zscaler management (work-related but macOS-specific)
    alias start-zscaler="open -a /Applications/Zscaler/Zscaler.app --hide; sudo find /Library/LaunchDaemons -name '*zscaler*' -exec launchctl load {} \;"
    alias kill-zscaler="find /Library/LaunchAgents -name '*zscaler*' -exec launchctl unload {} \;;sudo find /Library/LaunchDaemons -name '*zscaler*' -exec launchctl unload {} \;"
fi

# =========================
# Search Functions
# =========================
# GitHub search function
gh_search() {
    if [ $# -eq 0 ]; then
        echo "Usage: gh_search [-o|--org] <search term>"
        echo "  -o, --org    Search only organization"
        return 1
    fi
    
    local org_flag=""
    local query=""
    
    # Check for --org or -o flag
    if [ "$1" = "--org" ] || [ "$1" = "-o" ]; then
        org_flag="org%3A${GITHUB_ORG}+"
        shift
    fi
    
    query="$*"
    open "https://github.com/search?q=${org_flag}${query// /+}&type=code"
}

# Brave search function
brave() {
    if [ $# -eq 0 ]; then
        echo "Usage: brave <search term>"
        return 1
    fi
    local query="$*"
    open "https://search.brave.com/search?q=${query// /+}"
}

# Search aliases
alias search='brave'
alias s=search
alias ghs='gh_search'        # Search all of GitHub
alias ghso='gh_search --org' # Search only organization

# =========================
# Machine-Specific Configuration
# =========================
# Source local machine config (not synced - for machine-specific apps, aliases, etc.)
[[ -f ~/.zsh_local_rc ]] && source ~/.zsh_local_rc

# =========================
# Shell Completions
# =========================
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
[[ $commands[gh] ]] && source <(gh completion --shell zsh)

# =========================
# Prompt: Starship (load last among prompt setters)
# =========================
export XDG_CONFIG_HOME="$HOME/.config"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
eval "$(starship init zsh)"

# =========================
# Transient prompt (auto via zinit) + vicmd_symbol-safe hooks
# =========================
TRANSIENT_PROMPT_TRANSIENT_PROMPT='%(?.%F{green}.%F{red})❯%f '
TRANSIENT_PROMPT_TRANSIENT_RPROMPT=''
zinit light olets/zsh-transient-prompt

# Cursor + prompt redraw to keep Starship's ❮/❯ in sync with keymap
_cursor_by_keymap() {
  case "${KEYMAP:-}" in
    vicmd) printf '\e[2 q' ;;  # steady block
    *)     printf '\e[5 q' ;;  # blinking bar
  esac
}
_zp_keymap_select() { _cursor_by_keymap; zle reset-prompt }
_zp_line_init()     { _cursor_by_keymap; zle reset-prompt }
zle -N zle-keymap-select _zp_keymap_select
zle -N zle-line-init _zp_line_init
_cursor_precmd()    { _cursor_by_keymap }
add-zsh-hook precmd _cursor_precmd

# =========================
# TBD...
# =========================

