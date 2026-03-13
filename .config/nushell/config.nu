# =========================
# Shell Settings
# =========================
$env.config.show_banner = false
$env.config.edit_mode = "vi"
$env.config.buffer_editor = "nvim"
$env.config.error_style = "fancy"
$env.config.highlight_resolved_externals = true
$env.config.color_config.shape_external_resolved = "green_bold"
$env.config.color_config.shape_external = "red"
$env.config.color_config.shape_internalcall = "green_bold"
$env.config.color_config.shape_externalarg = "default"

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
        completer: {|spans| carapace $spans.0 nushell ...$spans | from json}
    }
    use_ls_colors: true
}

# =========================
# Completion Menu (IDE-style dropdown)
# =========================
$env.config.menus = [
    {
        name: completion_menu
        only_buffer_difference: false
        marker: ""
        type: {
            layout: ide
            min_completion_width: 0
            max_completion_width: 80
            max_completion_height: 10
            padding: 0
            border: true
            cursor_offset: 0
            description_mode: "prefer_right"
            min_description_width: 20
        }
        style: {
            text: green
            selected_text: { attr: r }
            description_text: yellow
        }
    }
]

# =========================
# Keybindings
# =========================
$env.config.keybindings = [
    # Ctrl+F: fzf directory picker with preview
    {
        name: fzf_cd
        modifier: control
        keycode: char_f
        mode: [emacs, vi_insert]
        event: {
            send: executehostcommand
            cmd: "cd (ls | where type == dir | get name | to text | fzf --preview 'ls -la {}' | str trim)"
        }
    }
    # Ctrl+R: fzf-powered history search
    {
        name: fzf_history
        modifier: control
        keycode: char_r
        mode: [emacs, vi_insert]
        event: {
            send: executehostcommand
            cmd: "commandline edit --replace (history | get command | reverse | uniq | to text | fzf --height 40% | str trim)"
        }
    }
]

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
