#!/usr/bin/env bash
set -e

# Clone the git repo of the Stable Diffusion Web UI by Automatic1111
# and set version
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd /stable-diffusion-webui
git checkout tags/${WEBUI_VERSION}

# Create and activate venv
python3 -m venv --system-site-packages /venv
source /venv/bin/activate

# Upgrade pip and setuptools
pip install --upgrade pip setuptools wheel

# Install torch and xformers
pip3 install --no-cache-dir torch==${TORCH_VERSION} torchvision torchaudio --index-url ${INDEX_URL}
pip3 install --no-cache-dir xformers==${XFORMERS_VERSION} --index-url ${INDEX_URL}

# Install A1111
# Use community fork since Stability-AI made their repo private
export STABLE_DIFFUSION_REPO="https://github.com/w-e-w/stablediffusion.git"

# Fix version pins that don't have wheels for Python 3.12
# - Pillow 9.5.0 has no Python 3.12 wheel, use system version
# - blendmodes==2022 requires Pillow<10, update to 2024+ which works with Pillow 10+
# - tokenizers <0.14 has no Python 3.12 wheel, allow newer versions
# - transformers==4.30.2 requires tokenizers<0.14, update to compatible version
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
if [ "$PYTHON_VERSION" == "3.12" ]; then
    sed -i '/^Pillow/d' requirements_versions.txt
    sed -i 's/^blendmodes.*/blendmodes>=2024/' requirements_versions.txt
    sed -i 's/^tokenizers.*/tokenizers>=0.14/' requirements_versions.txt
    sed -i 's/^transformers.*/transformers>=4.36/' requirements_versions.txt
fi

pip3 install -r requirements_versions.txt
python3 -c "from launch import prepare_environment; prepare_environment()" --skip-torch-cuda-test

# Clone the Automatic1111 Extensions
git clone https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet
git clone --depth=1 https://github.com/deforum-art/sd-webui-deforum.git extensions/deforum
git clone --depth=1 https://github.com/ashleykleynhans/a1111-sd-webui-locon.git extensions/a1111-sd-webui-locon
git clone --depth=1 https://codeberg.org/Gourieff/sd-webui-reactor.git extensions/sd-webui-reactor
git clone --depth=1 https://github.com/zanllp/sd-webui-infinite-image-browsing.git extensions/infinite-image-browsing
git clone --depth=1 https://github.com/Uminosachi/sd-webui-inpaint-anything.git extensions/inpaint-anything
git clone --depth=1 https://github.com/Bing-su/adetailer.git extensions/adetailer
git clone --depth=1 https://github.com/civitai/sd_civitai_extension.git extensions/sd_civitai_extension
git clone https://github.com/BlafKing/sd-civitai-browser-plus.git extensions/sd-civitai-browser-plus
git clone --depth=1 https://github.com/mcmonkeyprojects/sd-dynamic-thresholding extensions/sd-dynamic-thresholding

# Install dependencies for various extensions
cd /stable-diffusion-webui/extensions/deforum
pip3 install -r requirements.txt
cd /stable-diffusion-webui/extensions/sd-webui-reactor
pip3 install -r requirements.txt
pip3 install onnxruntime-gpu
cd /stable-diffusion-webui/extensions/infinite-image-browsing
# Remove av version constraint - av 16.x already installed by deforum and works fine
sed -i '/^av/d' requirements.txt
pip3 install -r requirements.txt
cd /stable-diffusion-webui/extensions/adetailer
python3 -m install
cd /stable-diffusion-webui/extensions/sd_civitai_extension
pip3 install -r requirements.txt

# Install dynamic thresholding extension
cd /stable-diffusion-webui/extensions/sd-dynamic-thresholding
sed -i '/license = { file = "LICENSE.txt" }/d' pyproject.toml
cat >> pyproject.toml << 'EOF'

[tool.setuptools]
py-modules = ["__init__"]
EOF
pip3 install .

# Install inpaint anything extension
cd /stable-diffusion-webui/extensions/inpaint-anything
python3 -m install

# Install dependencies for Civitai Browser+ extension
cd /stable-diffusion-webui/extensions/sd-civitai-browser-plus
pip3 install send2trash beautifulsoup4 ZipUnicode fake-useragent packaging pysocks

# Install dependencies for ControlNet extension last so other extensions don't interfere with it
cd /stable-diffusion-webui/extensions/sd-webui-controlnet
pip3 install -r requirements.txt

# Fix protobuf which could be incorrectly upgraded to an incompatible version by one of the
# other dependencies
pip3 install protobuf==3.20.0

# Pin mediapipe to a version that has the legacy solutions API (needed by controlnet_aux)
# and is compatible with protobuf 3.20.x
pip3 install mediapipe==0.10.14

# Fix numpy binary incompatibility with scikit-image
pip3 install --force-reinstall --no-cache-dir scikit-image
pip3 cache purge
deactivate

# Add inswapper model for the ReActor extension
mkdir -p /stable-diffusion-webui/models/insightface
cd /stable-diffusion-webui/models/insightface
wget -O inswapper_128.onnx "https://huggingface.co/ashleykleynhans/inswapper/resolve/main/inswapper_128.onnx?download=true"

# Configure ReActor to use the GPU instead of the CPU
echo "CUDA" > /stable-diffusion-webui/extensions/sd-webui-reactor/last_device.txt
