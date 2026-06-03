#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
CONFIG_FILE="${SCRIPT_DIR}/apps.conf"
OUTPUT_DIR="${SCRIPT_DIR}/Launchers"

DEFAULT_FLAGS=(
  "--disable-gpu"
  "--disable-gpu-compositing"
  "--disable-accelerated-video-decode"
  "--disable-features=UseSkiaRenderer,CanvasOopRasterization,Vulkan,Metal"
)

while IFS='|' read -r display_name app_path; do
  if [[ -z "${display_name}" || "${display_name}" == \#* ]]; then
    continue
  fi

  "${SCRIPT_DIR}/build-launcher.zsh" \
    "${app_path}" \
    "${display_name}" \
    "${OUTPUT_DIR}" \
    "${DEFAULT_FLAGS[@]}"
done < "${CONFIG_FILE}"

/bin/echo "Built safe launchers in ${OUTPUT_DIR}"
