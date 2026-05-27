#!/bin/bash
set -e

# Access the full path using ZED_FILE
full_path="$ZED_FILE"

# Extract filename with extension
filename_ext=$(basename "$full_path")

# Extract filename and extension
filename="${filename_ext%.*}"
extension="${filename_ext##*.}"

echo "[running $filename_ext]"

if [ "$extension" = "ts" ]; then
    tsc "$full_path" && node "${full_path%.ts}.js"
elif [ "$extension" = "py" ]; then
    uv run python "$full_path"
elif [ "$extension" = "zig" ]; then
    zig run "$full_path"
else
    echo "no"
fi
