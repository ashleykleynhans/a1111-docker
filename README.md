<div align="center">

# Docker image for A1111 Stable Diffusion Web UI

![Docker Pulls](https://img.shields.io/docker/pulls/ashleykza/a1111?style=for-the-badge&logo=docker&label=Docker%20Pulls&link=https%3A%2F%2Fhub.docker.com%2Frepository%2Fdocker%2Fashleykza%2Fa1111%2Fgeneral)

</div>

## Available Image Variants

| Docker Image Tag | CUDA | Python | Torch | xformers     | RunPod                                                                      |
|------------------|------|--------|-------|--------------|-----------------------------------------------------------------------------|
| cu124-py311      | 12.4 | 3.11   | 2.6.0 | 0.0.29.post3 | [Deploy](https://console.runpod.io/deploy?template=ts8ze6urzh&ref=2xxro4sy) |
| cu124-py312      | 12.4 | 3.12   | 2.6.0 | 0.0.29.post3 |                                                                             |
| cu128-py311      | 12.8 | 3.11   | 2.9.1 | 0.0.33       | [Deploy](https://console.runpod.io/deploy?template=deou4y116a&ref=2xxro4sy) |
| cu128-py312      | 12.8 | 3.12   | 2.9.1 | 0.0.33       |                                                                             |

## Installs

* Ubuntu 22.04 LTS
* [Jupyter Lab](https://github.com/jupyterlab/jupyterlab)
* [code-server](https://github.com/coder/code-server)
* [Automatic1111 Stable Diffusion Web UI](
  https://github.com/AUTOMATIC1111/stable-diffusion-webui) 1.10.1
* [ControlNet extension](
  https://github.com/Mikubill/sd-webui-controlnet) v1.1.455
* [After Detailer extension](
  https://github.com/Bing-su/adetailer) v25.3.0
* [ReActor extension](https://github.com/Gourieff/sd-webui-reactor)
* [Deforum extension](https://github.com/deforum-art/sd-webui-deforum)
* [Inpaint Anything extension](https://github.com/Uminosachi/sd-webui-inpaint-anything)
* [Infinite Image Browsing extension](https://github.com/zanllp/sd-webui-infinite-image-browsing)
* [CivitAI extension](https://github.com/civitai/sd_civitai_extension)
* [CivitAI Browser+ extension](https://github.com/BlafKing/sd-civitai-browser-plus)
* [Stable Diffusion Dynamic Thresholding (CFG Scale Fix) extension](https://github.com/mcmonkeyprojects/sd-dynamic-thresholding)
* [inswapper_128.onnx](
  https://github.com/facefusion/facefusion-assets/releases/download/models/inswapper_128.onnx)
* [runpodctl](https://github.com/runpod/runpodctl)
* [OhMyRunPod](https://github.com/kodxana/OhMyRunPod)
* [RunPod File Uploader](https://github.com/kodxana/RunPod-FilleUploader)
* [croc](https://github.com/schollz/croc)
* [rclone](https://rclone.org/)
* [Application Manager](https://github.com/ashleykleynhans/app-manager)
* [CivitAI Downloader](https://github.com/ashleykleynhans/civitai-downloader)

## Available on RunPod

This image is designed to work on [RunPod](https://runpod.io?ref=2xxro4sy).

| Name                                    | Docker Image                       | RunPod Template                                                             |
|-----------------------------------------|------------------------------------|-----------------------------------------------------------------------------|
| A1111 Stable Diffusion 1.10.1 CUDA 12.4 | ashleykza/a1111:cu124-py311-1.10.1 | [Deploy](https://console.runpod.io/deploy?template=ts8ze6urzh&ref=2xxro4sy) |
| A1111 Stable Diffusion 1.10.1 CUDA 12.8 | ashleykza/a1111:cu128-py311-1.10.1 | [Deploy](https://console.runpod.io/deploy?template=deou4y116a&ref=2xxro4sy) |

## Downloading models

```bash
cd /workspace/stable-diffusion-webui/models/Stable-diffusion
wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
wget https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors
cd /workspace/stable-diffusion-webui/models/VAE
wget https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors
```

## Building the Docker image

> [!NOTE]
> You will need to edit the `docker-bake.hcl` file and update `REGISTRY_USER`,
> and `RELEASE`.  You can obviously edit the other values too, but these
> are the most important ones.

> [!IMPORTANT]
> In order to cache the models, you will need at least 32GB of CPU/system
> memory (not VRAM) due to the large size of the models.  If you have less
> than 32GB of system memory, you can comment out or remove the code in the
> `Dockerfile` that caches the models.

```bash
# Clone the repo
git clone https://github.com/ashleykleynhans/a1111-docker.git

# Download the models
cd a1111-docker
wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
wget https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors
wget https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors

# Log in to Docker Hub
docker login

# Build the default target (cu124-py311) and push to Docker Hub
docker buildx bake -f docker-bake.hcl --push

# Build a specific target
docker buildx bake -f docker-bake.hcl cu124-py312 --push

# Build all targets
docker buildx bake -f docker-bake.hcl --push all

# Customize registry/user/release:
REGISTRY=ghcr.io REGISTRY_USER=myuser RELEASE=my-release docker buildx \
    bake -f docker-bake.hcl --push
```

### Available Build Targets

| Target | Description |
|--------|-------------|
| `cu124-py311` | CUDA 12.4, Python 3.11 (default) |
| `cu124-py312` | CUDA 12.4, Python 3.12 |
| `cu128-py311` | CUDA 12.8, Python 3.11 |
| `cu128-py312` | CUDA 12.8, Python 3.12 |
| `all` | Build all targets |

## Running Locally

### Install Nvidia CUDA Driver

- [Linux](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)
- [Windows](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html)

### Start the Docker container

```bash
docker run -d \
  --gpus all \
  -v /workspace \
  -p 3000:3001 \
  -p 7777:7777 \
  -p 8000:8000 \
  -p 8888:8888 \
  -p 2999:2999 \
  -e VENV_PATH=/workspace/venvs/a1111 \
  ashleykza/a1111:cu124-py311-1.10.1
```

Replace `cu124-py311-1.10.1` with your preferred variant and version. See [Available Image Variants](#available-image-variants) for options.

### Ports

| Connect Port | Internal Port | Description                   |
|--------------|---------------|-------------------------------|
| 3000         | 3001          | A1111 Stable Diffusion Web UI |
| 7777         | 7777          | Code Server                   |
| 8000         | 8000          | Application Manager           |
| 8888         | 8888          | Jupyter Lab                   |
| 2999         | 2999          | RunPod File Uploader          |

### Environment Variables

| Variable             | Description                                      | Default                |
|----------------------|--------------------------------------------------|------------------------|
| VENV_PATH            | Set the path for the Python venv for the app     | /workspace/venvs/a1111 |
| JUPYTER_LAB_PASSWORD | Set a password for Jupyter lab                   | not set - no password  |
| DISABLE_AUTOLAUNCH   | Disable Web UIs from launching automatically     | (not set)              |
| DISABLE_SYNC         | Disable syncing if using a RunPod network volume | (not set)              |

## Logs

Stable Diffusion Web UI creates a log file, and you can tail it instead of
killing the services to view the logs.

| Application             | Log file                     |
|-------------------------|------------------------------|
| Stable Diffusion Web UI | /workspace/logs/webui.log    |

For example:

```bash
tail -f /workspace/logs/webui.log
```

## Community and Contributing

Pull requests and issues on [GitHub](https://github.com/ashleykleynhans/a1111-docker)
are welcome. Bug fixes and new features are encouraged.

## Appreciate my work?

<a href="https://www.buymeacoffee.com/ashleyk" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
