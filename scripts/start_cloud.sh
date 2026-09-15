#!/usr/bin/env bash
# One-shot start for a Linux GPU machine (RunPod PyTorch pod, Lambda, Vast.ai, GCP/AWS VM…).
#   bash scripts/start_cloud.sh
# Weights go to $WEIGHTS_DIR (default /workspace/weights, i.e. the RunPod volume),
# so a restarted pod does not re-download ~45 GB.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v ffmpeg >/dev/null 2>&1; then
  apt-get update -qq && apt-get install -y -qq ffmpeg libsndfile1
fi

python -c "import torch; assert torch.cuda.is_available(), 'No CUDA GPU found'; print('GPU:', torch.cuda.get_device_name(0))"

pip install -q -r requirements.txt

export WEIGHTS_DIR="${WEIGHTS_DIR:-/workspace/weights}"
export HF_HOME="${HF_HOME:-/workspace/hf_cache}"
export GRADIO_SERVER_NAME="${GRADIO_SERVER_NAME:-0.0.0.0}"
export GRADIO_SERVER_PORT="${GRADIO_SERVER_PORT:-7860}"
mkdir -p "$WEIGHTS_DIR"

python app.py
