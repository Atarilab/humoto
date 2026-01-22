#!/bin/bash

base_dir=""
output_dir=""
python_args=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d)
            base_dir="$2"
            shift 2
            ;;
        -o)
            output_dir="$2"
            shift 2
            ;;
        *)
            python_args+=("$1")
            shift
            ;;
    esac
done

# Get base directory: use argument if provided, otherwise use env var, otherwise prompt
if [[ -z "$base_dir" ]]; then
    if [[ -n "$HUMOTO_DATASET_DIR" ]]; then
        base_dir="$HUMOTO_DATASET_DIR"
    else
        read -p "Enter humoto dataset directory: " base_dir
    fi
fi

# Check if directory exists
if [[ ! -d "$base_dir" ]]; then
    echo "Error: Directory '$base_dir' not found"
    exit 1
fi

# Ensure trailing slash
base_dir="${base_dir%/}/"

echo "Processing directory: $base_dir"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Convert output_dir to absolute path if provided
if [[ -n "$output_dir" ]]; then
    # Convert relative path to absolute
    if [[ "$output_dir" != /* ]]; then
        output_dir="$(cd "$(dirname "$output_dir" 2>/dev/null || echo .)" && pwd)/$(basename "$output_dir")"
    fi
    # Create the output directory
    mkdir -p "$output_dir"
fi

# Process all subdirectories
find "$base_dir" -mindepth 1 -type d | while read -r dir; do
    relative_path=${dir#"$base_dir/"}
    last_folder=$(echo "$relative_path" | awk -F'/' '{print $NF}')
    echo "-------------$last_folder---------------"
    # Convert to absolute path before changing directory
    abs_path="$(cd "$dir" && pwd)"
    if [[ -n "$output_dir" ]]; then
        (cd "$SCRIPT_DIR" && python clear_human_scale.py -d "$abs_path" -o "$output_dir" "${python_args[@]}")
    else
        (cd "$SCRIPT_DIR" && python clear_human_scale.py -d "$abs_path" "${python_args[@]}")
    fi
done
