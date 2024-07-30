#!/usr/bin/env bash

export PYTHONUNBUFFERED=1
export APP="stable-diffusion-webui"

TEMPLATE_NAME="a1111"
TEMPLATE_VERSION_FILE="/workspace/${APP}/template.json"

echo "Template name: ${TEMPLATE_NAME}"
echo "Template version: ${TEMPLATE_VERSION}"
echo "venv: ${VENV_PATH}"

if [[ -e ${TEMPLATE_VERSION_FILE} ]]; then
    EXISTING_TEMPLATE_NAME=$(jq -r '.template_name // empty' "$TEMPLATE_VERSION_FILE")

    if [[ -n "${EXISTING_TEMPLATE_NAME}" ]]; then
        if [[ "${EXISTING_TEMPLATE_NAME}" != "${TEMPLATE_NAME}" ]]; then
            EXISTING_VERSION="0.0.0"
        else
            EXISTING_VERSION=$(jq -r '.template_version // empty' "$TEMPLATE_VERSION_FILE")
        fi
    else
        EXISTING_VERSION="0.0.0"
    fi
else
    EXISTING_VERSION="0.0.0"
fi

save_template_json() {
    cat << EOF > ${TEMPLATE_VERSION_FILE}
{
    "template_name": "${TEMPLATE_NAME}",
    "template_version": "${TEMPLATE_VERSION}"
}
EOF
}

sync_directory() {
    local src_dir="$1"
    local dst_dir="$2"

    echo "Syncing from $src_dir to $dst_dir"

    # Ensure destination directory exists
    mkdir -p "$dst_dir"

    # Check whether /workspace is fuse, overlay, or xfs
    local workspace_fs=$(df -T /workspace | awk 'NR==2 {print $2}')

    if [ "$workspace_fs" = "fuse" ]; then
        echo "Using tar and pigz for sync (fuse filesystem detected)"

        # Get total size of source directory
        local total_size=$(du -sb "$src_dir" | cut -f1)

        # Use parallel tar with fast compression and exclusions
        tar --use-compress-program="pigz -p 4" \
            --exclude='*.pyc' \
            --exclude='__pycache__' \
            --exclude='*.log' \
            -cf - -C "$src_dir" . | \
        pv -s $total_size | \
        tar --use-compress-program="pigz -p 4" -xf - -C "$dst_dir"
    elif [ "$workspace_fs" = "overlay" ] || [ "$workspace_fs" = "xfs" ]; then
        echo "Using rsync for sync ($workspace_fs filesystem detected)"
        rsync -rlptDu "$src_dir/" "$dst_dir/"
    else
        echo "Unknown filesystem type for /workspace: $workspace_fs, defaulting to rsync"
        rsync -rlptDu "$src_dir/" "$dst_dir/"
    fi

    echo "Sync completed"
}

sync_apps() {
    # Only sync if the DISABLE_SYNC environment variable is not set
    if [ -z "${DISABLE_SYNC}" ]; then
        # Sync main venv to workspace to support Network volumes
        echo "Syncing main venv to workspace, please wait..."
        sync_directory "/venv" "${VENV_PATH}"

        # Sync application to workspace to support Network volumes
        echo "Syncing ${APP} to workspace, please wait..."
        sync_directory "/${APP}" "/workspace/${APP}"

        save_template_json
        echo "${VENV_PATH}" > "/workspace/${APP}/venv_path"
    fi
}

fix_venvs() {
    echo "Fixing Stable Diffusion Web UI venv..."
    /fix_venv.sh /venv ${VENV_PATH}
}

link_models() {
   # Link models and VAE if they are not already linked
   if [[ ! -L /workspace/stable-diffusion-webui/models/Stable-diffusion/sd_xl_base_1.0.safetensors ]]; then
       ln -s /sd-models/sd_xl_base_1.0.safetensors /workspace/stable-diffusion-webui/models/Stable-diffusion/sd_xl_base_1.0.safetensors
   fi

   if [[ ! -L /workspace/stable-diffusion-webui/models/Stable-diffusion/sd_xl_refiner_1.0.safetensors ]]; then
       ln -s /sd-models/sd_xl_refiner_1.0.safetensors /workspace/stable-diffusion-webui/models/Stable-diffusion/sd_xl_refiner_1.0.safetensors
   fi

   if [[ ! -L /workspace/stable-diffusion-webui/models/VAE/sdxl_vae.safetensors ]]; then
       ln -s /sd-models/sdxl_vae.safetensors /workspace/stable-diffusion-webui/models/VAE/sdxl_vae.safetensors
   fi
}

if [ "$(printf '%s\n' "$EXISTING_VERSION" "$TEMPLATE_VERSION" | sort -V | head -n 1)" = "$EXISTING_VERSION" ]; then
    if [ "$EXISTING_VERSION" != "$TEMPLATE_VERSION" ]; then
        sync_apps
        fix_venvs
        link_models

        # Create logs directory
        mkdir -p /workspace/logs
    else
        echo "Existing version is the same as the template version, no syncing required."
    fi
else
    echo "Existing version is newer than the template version, not syncing!"
fi

# Add VENV_PATH to webui-user.sh
sed -i "s|venv_dir=VENV_PATH|venv_dir=\"${VENV_PATH}\"|" /workspace/stable-diffusion-webui/webui-user.sh

# Start application manager
cd /app-manager
npm start > /workspace/logs/app-manager.log 2>&1 &

if [[ ${DISABLE_AUTOLAUNCH} ]]
then
    echo "Auto launching is disabled so the applications will not be started automatically"
    echo "You can launch them manually using the launcher scripts:"
    echo ""
    echo "   Stable Diffusion Web UI:"
    echo "   ---------------------------------------------"
    echo "   /start_a1111.sh"
else
    /start_a1111.sh
fi

echo "All services have been started"
