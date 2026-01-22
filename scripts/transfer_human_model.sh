#!/bin/bash

base_dir=""
human_model=""
output_dir=""
python_args=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d)
            base_dir="$2"
            shift 2
            ;;
        -m)
            human_model="$2"
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
        read -p "Enter base directory: " base_dir
    fi
fi

if [[ -z "$human_model" ]]; then
    read -p "Enter human model path: " human_model
fi

# Check if directory exists
if [[ ! -d "$base_dir" ]]; then
    echo "Error: Directory '$base_dir' not found"
    exit 1
fi

# Convert human_model to absolute path if it's relative
if [[ -n "$human_model" ]]; then
    if [[ "$human_model" != /* ]]; then
        # It's a relative path, convert to absolute based on current working directory
        # Get the absolute path of the directory containing the file
        model_dir="$(dirname "$human_model")"
        model_file="$(basename "$human_model")"
        if [[ "$model_dir" == "." ]]; then
            # No directory component, just use current directory
            human_model="$(pwd)/$model_file"
        else
            # Has directory component, resolve it
            if cd "$model_dir" 2>/dev/null; then
                human_model="$(pwd)/$model_file"
            else
                human_model="$(pwd)/$human_model"
            fi
        fi
    fi
fi

if [[ ! -f "$human_model" ]]; then
    echo "Error: File '$human_model' not found"
    exit 1
fi

# Ensure trailing slash
base_dir="${base_dir%/}/"

echo "Processing directory: $base_dir"

# Convert output_dir to absolute path if provided
if [[ -n "$output_dir" ]]; then
    # Convert relative path to absolute
    if [[ "$output_dir" != /* ]]; then
        output_dir="$(cd "$(dirname "$output_dir" 2>/dev/null || echo .)" && pwd)/$(basename "$output_dir")"
    fi
    # Create the output directory
    mkdir -p "$output_dir"
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Process all subdirectories
find "$base_dir" -mindepth 1 -type d | while read -r dir; do
    relative_path=${dir#"$base_dir/"}
    last_folder=$(echo "$relative_path" | awk -F'/' '{print $NF}')
    echo "-------------$last_folder---------------"
    # Convert to absolute path before changing directory
    abs_path="$(cd "$dir" && pwd)"
    if [[ -n "$output_dir" ]]; then
        (cd "$SCRIPT_DIR" && python transfer_human_model.py -d "$abs_path" -m "$human_model" -o "$output_dir" "${python_args[@]}")
    else
        (cd "$SCRIPT_DIR" && python transfer_human_model.py -d "$abs_path" -m "$human_model" "${python_args[@]}")
    fi
done
