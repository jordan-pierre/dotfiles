# =========================
# Personal Configuration
# =========================
# Machine-specific env vars (run scripts/setup.sh to create on a new machine)
const personal_env = ($nu.home-dir | path join ".config" "shell" "personal.nu")
if ($personal_env | path exists) {
    source $personal_env
}

# =========================
# PATH
# =========================
$env.PATH = ($env.PATH | split row (char esep))

$env.PATH = ($env.PATH | prepend [
    ($nu.home-dir | path join ".local" "bin")
    "/usr/local/bin"
])

if ($nu.os-info.name == "macos") {
    $env.PATH = ($env.PATH | prepend "/opt/homebrew/bin")
    $env.PATH = ($env.PATH | append "/Applications/WezTerm.app/Contents/MacOS")
    $env.WEZTERM_SHELL_SKIP_ALL = "1"
}

$env.PATH = ($env.PATH | uniq)

# =========================
# Environment Variables
# =========================
$env.XDG_CONFIG_HOME = ($nu.home-dir | path join ".config")

# LS_COLORS via vivid (cyberdream — matches wezterm theme)
$env.LS_COLORS = (vivid generate cyberdream)
$env.STARSHIP_CONFIG = ($env.XDG_CONFIG_HOME | path join "starship" "starship.toml")
$env.VIRTUAL_ENV_DISABLE_PROMPT = "1"

if ("AWS_PROFILE" in $env) and ($env.AWS_PROFILE | is-not-empty) {
    $env.AWS_DEFAULT_PROFILE = $env.AWS_PROFILE
}

# =========================
# Tool Initializations
# =========================
# Generate init scripts into cache dir (re-run on shell startup to stay current)
let cache = ($nu.cache-dir)

starship init nu | save -f ($cache | path join "starship-init.nu")
zoxide init nushell | save -f ($cache | path join "zoxide-init.nu")
carapace _carapace nushell | save -f ($cache | path join "carapace-init.nu")
