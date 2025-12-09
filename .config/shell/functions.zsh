# =========================
# Omarchy-Style Shell Functions
# =========================

# Compression & Extraction
# =========================

# Compress a directory into a tar.gz archive
compress() {
  if [ $# -eq 0 ]; then
    echo "Usage: compress <directory>"
    return 1
  fi
  tar -czf "${1%/}.tar.gz" "$1"
  echo "Compressed $1 to ${1%/}.tar.gz"
}

# Extract various archive formats
extract() {
  if [ $# -eq 0 ]; then
    echo "Usage: extract <archive>"
    return 1
  fi
  
  if [ ! -f "$1" ]; then
    echo "Error: File not found: $1"
    return 1
  fi
  
  case "$1" in
    *.tar.gz|*.tgz)
      tar -xzf "$1"
      echo "Extracted $1"
      ;;
    *.tar.bz2|*.tbz2)
      tar -xjf "$1"
      echo "Extracted $1"
      ;;
    *.tar)
      tar -xf "$1"
      echo "Extracted $1"
      ;;
    *.zip)
      unzip "$1"
      echo "Extracted $1"
      ;;
    *.gz)
      gunzip "$1"
      echo "Extracted $1"
      ;;
    *.bz2)
      bunzip2 "$1"
      echo "Extracted $1"
      ;;
    *.rar)
      unrar x "$1"
      echo "Extracted $1"
      ;;
    *.7z)
      7z x "$1"
      echo "Extracted $1"
      ;;
    *)
      echo "Error: Unknown archive format: $1"
      echo "Supported formats: .tar.gz, .tar.bz2, .tar, .zip, .gz, .bz2, .rar, .7z"
      return 1
      ;;
  esac
}

# Image Conversion Functions
# =========================

# Convert images to JPG format
img2jpg() {
  if [ $# -eq 0 ]; then
    echo "Usage: img2jpg <image1> [image2] [image3] ..."
    echo "Converts images to JPG format using ImageMagick"
    return 1
  fi
  
  for img in "$@"; do
    if [ ! -f "$img" ]; then
      echo "Warning: File not found, skipping: $img"
      continue
    fi
    
    local output="${img%.*}.jpg"
    convert "$img" "$output"
    echo "Converted: $img → $output"
  done
}

# Convert images to PNG format
img2png() {
  if [ $# -eq 0 ]; then
    echo "Usage: img2png <image1> [image2] [image3] ..."
    echo "Converts images to PNG format using ImageMagick"
    return 1
  fi
  
  for img in "$@"; do
    if [ ! -f "$img" ]; then
      echo "Warning: File not found, skipping: $img"
      continue
    fi
    
    local output="${img%.*}.png"
    convert "$img" "$output"
    echo "Converted: $img → $output"
  done
}

# Convert images to WebP format (modern, efficient)
img2webp() {
  if [ $# -eq 0 ]; then
    echo "Usage: img2webp <image1> [image2] [image3] ..."
    echo "Converts images to WebP format using ImageMagick"
    return 1
  fi
  
  for img in "$@"; do
    if [ ! -f "$img" ]; then
      echo "Warning: File not found, skipping: $img"
      continue
    fi
    
    local output="${img%.*}.webp"
    convert "$img" "$output"
    echo "Converted: $img → $output"
  done
}

# Resize image to specific width (maintains aspect ratio)
imgresize() {
  if [ $# -lt 2 ]; then
    echo "Usage: imgresize <width> <image1> [image2] [image3] ..."
    echo "Example: imgresize 1920 photo.jpg"
    return 1
  fi
  
  local width="$1"
  shift
  
  for img in "$@"; do
    if [ ! -f "$img" ]; then
      echo "Warning: File not found, skipping: $img"
      continue
    fi
    
    local output="${img%.*}_${width}w.${img##*.}"
    convert "$img" -resize "${width}x" "$output"
    echo "Resized: $img → $output (width: ${width}px)"
  done
}

# Metadata Management
# =========================

# Scrub metadata from images and PDFs
scrub_metadata() {
  if [ $# -eq 0 ]; then
    echo "Usage: scrub_metadata <file1> [file2] [file3] ..."
    echo "Removes EXIF and metadata from images and PDFs"
    echo "Supported formats: jpg, jpeg, png, pdf"
    return 1
  fi
  
  for file in "$@"; do
    if [ ! -f "$file" ]; then
      echo "Warning: File not found, skipping: $file"
      continue
    fi
    
    case "$file" in
      *.jpg|*.jpeg|*.png)
        exiftool -all= -overwrite_original "$file"
        echo "✓ Metadata scrubbed: $file"
        ;;
      *.pdf)
        exiftool -all:all= -overwrite_original "$file"
        echo "✓ Metadata scrubbed: $file"
        ;;
      *)
        echo "✗ Unsupported file type: $file"
        echo "  Supported: .jpg, .jpeg, .png, .pdf"
        ;;
    esac
  done
}

# View metadata from images and PDFs
view_metadata() {
  if [ $# -eq 0 ]; then
    echo "Usage: view_metadata <file>"
    echo "Displays EXIF and metadata from images and PDFs"
    return 1
  fi
  
  exiftool "$1"
}

# Utility Functions
# =========================

# Create a directory and cd into it
mkcd() {
  if [ $# -eq 0 ]; then
    echo "Usage: mkcd <directory>"
    return 1
  fi
  mkdir -p "$1" && cd "$1"
}

# Quick backup of a file (creates file.bak)
backup() {
  if [ $# -eq 0 ]; then
    echo "Usage: backup <file>"
    return 1
  fi
  cp "$1" "$1.bak"
  echo "Backed up: $1 → $1.bak"
}

# Get the weather for a location
weather() {
  local location="${1:-}"
  curl "wttr.in/${location}"
}

# Generate a random password
genpass() {
  local length="${1:-16}"
  LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c "$length"
  echo
}

# Quick HTTP server in current directory
serve() {
  local port="${1:-8000}"
  echo "Starting HTTP server on port $port..."
  python3 -m http.server "$port"
}

# Git Functions
# =========================

# Open current repo remote (default: origin) in browser
ghr() {
  local remote="${1:-origin}"
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not a git repository" >&2
    return 1
  fi

  local url
  if ! url=$(git remote get-url "$remote" 2>/dev/null); then
    url=$(git config --get "remote.${remote}.url")
  fi

  if [[ -z "$url" ]]; then
    echo "Remote '$remote' not found" >&2
    return 1
  fi

  local https_url="$url"
  if [[ "$url" == git@*:* ]]; then
    local host="${url#git@}"
    host="${host%%:*}"
    local path="${url#*:}"
    https_url="https://${host}/${path}"
  elif [[ "$url" == ssh://* ]]; then
    local without_scheme="${url#ssh://}"
    local host="${without_scheme%%/*}"
    host="${host#*@}"
    local path="${without_scheme#*/}"
    https_url="https://${host}/${path}"
  fi

  https_url="${https_url%.git}"
  [[ "$https_url" != */ ]] && https_url="${https_url}/"

  if command -v open >/dev/null 2>&1; then
    open "$https_url"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$https_url"
  else
    echo "$https_url"
  fi
}
