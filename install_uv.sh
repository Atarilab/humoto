#!/bin/bash
# Installation script using uv

# Create virtual environment with Python 3.10
uv venv --python 3.10

# Activate the virtual environment
source .venv/bin/activate

# Install bpy from Blender's PyPI
uv pip install bpy==4.0.0 --extra-index-url https://download.blender.org/pypi/

# Install PyTorch with CUDA 12.1 support (compatible with CUDA 12.8)
# Note: If you need CUDA 11.8, change cu121 to cu118 and use torch==2.1.2
uv pip install torch==2.2.0 torchvision==0.17.0 torchaudio==2.2.0 --index-url https://download.pytorch.org/whl/cu121

# Install other requirements
uv pip install -r requirements.txt

# Install iopath (required for PyTorch3D)
uv pip install iopath

# Install build dependencies (required for building PyTorch3D from source)
uv pip install setuptools wheel ninja

# Install PyTorch3D from GitHub (--no-build-isolation needed because it requires torch during build)
uv pip install "git+https://github.com/facebookresearch/pytorch3d.git" --no-build-isolation

echo "Installation complete! Activate the environment with: source .venv/bin/activate"