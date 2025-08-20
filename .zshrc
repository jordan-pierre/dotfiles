# Settings are based on: https://www.youtube.com/watch?v=ud7YxC33Z3w

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit
if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# To customize prompt, use oh-my-posh
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

# Keybindings
bindkey -e
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias k='kubectl'
alias uvr='uv run'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

fpath+=~/.zfunc; autoload -Uz compinit; compinit

# --- Oh My Posh: expose Vim mode to templates (instant flip) ---
# NOTE: This section should be at the end of the .zshrc

typeset -ga precmd_functions  # ensure array exists

_omp_run_precmds() {
  local f
  for f in $precmd_functions; do
    (( $+functions[$f] )) && $f
  done
}

typeset -g OMP_VIM_MODE="INSERT"

_omp_update_vim_mode() {
  if [[ "$KEYMAP" == vicmd ]]; then
    export OMP_VIM_MODE="NORMAL"
  else
    export OMP_VIM_MODE="INSERT"
  fi
  _omp_run_precmds
  zle -R
  zle reset-prompt
}

# Remove competing widgets first, then register ours
zle -D zle-keymap-select 2>/dev/null
zle -D zle-line-init     2>/dev/null
zle -N zle-keymap-select _omp_update_vim_mode
zle -N zle-line-init     _omp_update_vim_mode

# Enable vi mode LAST so our widget wins
bindkey -v
# --- Oh My Posh </End> ---
