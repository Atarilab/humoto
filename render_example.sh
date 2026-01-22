#!/bin/bash
# Example script to render a HUMOTO sequence
# Usage: bash render_example.sh <sequence_name> [output_folder]

# Default paths based on your dataset location
DATASET_DIR="../dataset/humoto/humoto_0805"
OBJECT_DIR="../dataset/humoto/humoto_objects_0805"
OUTPUT_DIR="${2:-./rendered_outputs}"

# Check if sequence name is provided
if [ -z "$1" ]; then
    echo "Usage: bash render_example.sh <sequence_name> [output_folder]"
    echo ""
    echo "Example:"
    echo "  bash render_example.sh activating_floor_lamp_with_right_hand-485"
    echo ""
    echo "Available sequences (first 10):"
    ls "$DATASET_DIR" | head -10
    exit 1
fi

SEQUENCE_NAME="$1"
SEQUENCE_PATH="$DATASET_DIR/$SEQUENCE_NAME"

# Check if sequence exists
if [ ! -d "$SEQUENCE_PATH" ]; then
    echo "Error: Sequence folder not found: $SEQUENCE_PATH"
    exit 1
fi

# Check if pkl file exists
if [ ! -f "$SEQUENCE_PATH/${SEQUENCE_NAME}.pkl" ]; then
    echo "Warning: PKL file not found: $SEQUENCE_PATH/${SEQUENCE_NAME}.pkl"
    echo "You may need to extract pickle data first using:"
    echo "  bash scripts/extract_pk_data.sh -d $DATASET_DIR"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Rendering sequence: $SEQUENCE_NAME"
echo "Sequence path: $SEQUENCE_PATH"
echo "Object models: $OBJECT_DIR"
echo "Output folder: $OUTPUT_DIR"
echo ""

python render_humoto_pytorch3d.py \
  -d "$SEQUENCE_PATH" \
  -o "$OUTPUT_DIR" \
  -m "$OBJECT_DIR" \
  -y -t -u
