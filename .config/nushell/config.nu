# =========================
# Shell Settings
# =========================
$env.config.show_banner = false
$env.config.edit_mode = "vi"
$env.config.buffer_editor = "nvim"
$env.config.error_style = "fancy"

$env.config.history = {
    max_size: 5000
    sync_on_enter: true
    file_format: "sqlite"
    isolation: false
}

$env.config.completions = {
    sort: "smart"
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "fuzzy"
    external: {
        enable: true
        max_results: 100
        completer: null
    }
    use_ls_colors: true
}

$env.config.cursor_shape = {
    emacs: "blink_line"
    vi_insert: "blink_line"
    vi_normal: "blink_block"
}

# =========================
# Prompt Indicators
# =========================
# Starship handles the prompt character (❯/❮), so suppress nushell's vi indicators
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""

# =========================
# Transient Prompt
# =========================
$env.TRANSIENT_PROMPT_COMMAND = {|| "❯ " }
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

# =========================
# Load Init Scripts
# =========================
const cache = $nu.cache-dir

source ($cache | path join "starship-init.nu")
source ($cache | path join "zoxide-init.nu")
source ($cache | path join "carapace-init.nu")

# =========================
# CLI Replacement Aliases
# =========================
alias ls = eza --icons --group-directories-first
alias ll = eza -l --icons --group-directories-first
alias la = eza -la --icons --group-directories-first
alias lt = eza --tree --level=2 --icons
alias cat = bat --paging=never
alias find = fd
alias vim = nvim
alias c = clear

# =========================
# TUI Tool Shortcuts
# =========================
alias lzd = lazydocker
alias lzg = lazygit
alias top = btop
alias sysinfo = fastfetch

# =========================
# Kubernetes
# =========================
alias k = kubectl

# =========================
# Navigation
# =========================
alias p = cd ~/Projects

# =========================
# Git Aliases
# =========================
alias gss = git status -s
alias gcam = git commit -a -m
alias gp = git push

# =========================
# GitHub Aliases
# =========================
alias ghr = gh browse

def ghrb [] {
    gh browse -b (git branch --show-current | str trim)
}

def ghrp [] {
    gh pr view --web
}

# =========================
# Search Functions
# =========================
def gh_search [
    --org (-o)  # Search only organization
    ...terms: string
] {
    if ($terms | is-empty) {
        print "Usage: gh_search [-o|--org] <search term>"
        return
    }

    let query = ($terms | str join "+")
    let org_prefix = if $org {
        let github_org = ($env | get -o GITHUB_ORG | default "")
        $"org%3A($github_org)+"
    } else {
        ""
    }
    ^open $"https://github.com/search?q=($org_prefix)($query)&type=code"
}

def brave [...terms: string] {
    if ($terms | is-empty) {
        print "Usage: brave <search term>"
        return
    }
    let query = ($terms | str join "+")
    ^open $"https://search.brave.com/search?q=($query)"
}

alias search = brave
alias s = search
alias ghs = gh_search
alias ghso = gh_search --org

# =========================
# Yazi TUI File Manager
# =========================
def --env y [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXX")
    yazi ...$args --cwd-file $tmp
    let cwd = (open $tmp)
    if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
    }
    rm -fp $tmp
}

# =========================
# Local Machine Config
# =========================
# For machine-specific config, add .nu files to ~/.config/nushell/autoload/
# They are sourced automatically by nushell on startup.
