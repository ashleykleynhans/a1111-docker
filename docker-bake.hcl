variable "REGISTRY" {
    default = "docker.io"
}

variable "REGISTRY_USER" {
    default = "ashleykza"
}

variable "APP" {
    default = "a1111"
}

variable "RELEASE" {
    default = "1.10.1"
}

variable "RELEASE_SUFFIX" {
    default = ".post6"
}

variable "BASE_IMAGE_REPOSITORY" {
    default = "ashleykza/runpod-base"
}

variable "BASE_IMAGE_VERSION" {
    default = "2.4.15"
}

variable "APP_MANAGER_VERSION" {
    default = "1.3.1"
}

variable "CIVITAI_DOWNLOADER_VERSION" {
    default = "3.0.0"
}

variable "CONTROLNET_COMMIT" {
    default = "56cec5b2958edf3b1807b7e7b2b1b5186dbd2f81"
}

variable "CIVITAI_BROWSER_PLUS_VERSION" {
    default = "v3.6.0"
}

variable "VENV_PATH" {
    default = "/workspace/venvs/a1111"
}

group "default" {
    targets = ["cu124-py311"]
}

group "all" {
    targets = [
        "cu124-py311",
        "cu124-py312",
        "cu128-py311",
        "cu128-py312"
    ]
}

target "cu124-py311" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:cu124-py311-${RELEASE}${RELEASE_SUFFIX}"]
    args = {
        RELEASE                      = "${RELEASE}"
        BASE_IMAGE                   = "${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_VERSION}-python3.11-cuda12.4.1-torch2.6.0"
        INDEX_URL                    = "https://download.pytorch.org/whl/cu124"
        TORCH_VERSION                = "2.6.0+cu124"
        XFORMERS_VERSION             = "0.0.29.post3"
        WEBUI_VERSION                = "v${RELEASE}"
        APP_MANAGER_VERSION          = "${APP_MANAGER_VERSION}"
        CIVITAI_DOWNLOADER_VERSION   = "${CIVITAI_DOWNLOADER_VERSION}"
        CONTROLNET_COMMIT            = "${CONTROLNET_COMMIT}"
        CIVITAI_BROWSER_PLUS_VERSION = "${CIVITAI_BROWSER_PLUS_VERSION}"
        VENV_PATH                    = "${VENV_PATH}"
    }
    platforms = ["linux/amd64"]
}

target "cu124-py312" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:cu124-py312-${RELEASE}${RELEASE_SUFFIX}"]
    args = {
        RELEASE                      = "${RELEASE}"
        BASE_IMAGE                   = "${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_VERSION}-python3.12-cuda12.4.1-torch2.6.0"
        INDEX_URL                    = "https://download.pytorch.org/whl/cu124"
        TORCH_VERSION                = "2.6.0+cu124"
        XFORMERS_VERSION             = "0.0.29.post3"
        WEBUI_VERSION                = "v${RELEASE}"
        APP_MANAGER_VERSION          = "${APP_MANAGER_VERSION}"
        CIVITAI_DOWNLOADER_VERSION   = "${CIVITAI_DOWNLOADER_VERSION}"
        CONTROLNET_COMMIT            = "${CONTROLNET_COMMIT}"
        CIVITAI_BROWSER_PLUS_VERSION = "${CIVITAI_BROWSER_PLUS_VERSION}"
        VENV_PATH                    = "${VENV_PATH}"
    }
    platforms = ["linux/amd64"]
}

target "cu128-py311" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:cu128-py311-${RELEASE}${RELEASE_SUFFIX}"]
    args = {
        RELEASE                      = "${RELEASE}"
        BASE_IMAGE                   = "${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_VERSION}-python3.11-cuda12.8.1-torch2.9.1"
        INDEX_URL                    = "https://download.pytorch.org/whl/cu128"
        TORCH_VERSION                = "2.9.1+cu128"
        XFORMERS_VERSION             = "0.0.33"
        WEBUI_VERSION                = "v${RELEASE}"
        APP_MANAGER_VERSION          = "${APP_MANAGER_VERSION}"
        CIVITAI_DOWNLOADER_VERSION   = "${CIVITAI_DOWNLOADER_VERSION}"
        CONTROLNET_COMMIT            = "${CONTROLNET_COMMIT}"
        CIVITAI_BROWSER_PLUS_VERSION = "${CIVITAI_BROWSER_PLUS_VERSION}"
        VENV_PATH                    = "${VENV_PATH}"
    }
    platforms = ["linux/amd64"]
}

target "cu128-py312" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:cu128-py312-${RELEASE}${RELEASE_SUFFIX}"]
    args = {
        RELEASE                      = "${RELEASE}"
        BASE_IMAGE                   = "${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_VERSION}-python3.12-cuda12.8.1-torch2.9.1"
        INDEX_URL                    = "https://download.pytorch.org/whl/cu128"
        TORCH_VERSION                = "2.9.1+cu128"
        XFORMERS_VERSION             = "0.0.33"
        WEBUI_VERSION                = "v${RELEASE}"
        APP_MANAGER_VERSION          = "${APP_MANAGER_VERSION}"
        CIVITAI_DOWNLOADER_VERSION   = "${CIVITAI_DOWNLOADER_VERSION}"
        CONTROLNET_COMMIT            = "${CONTROLNET_COMMIT}"
        CIVITAI_BROWSER_PLUS_VERSION = "${CIVITAI_BROWSER_PLUS_VERSION}"
        VENV_PATH                    = "${VENV_PATH}"
    }
    platforms = ["linux/amd64"]
}
