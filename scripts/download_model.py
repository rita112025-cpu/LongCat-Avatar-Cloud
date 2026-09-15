"""Download the LongCat-Video-Avatar 1.5 weights (~45 GB) from Hugging Face.

Only the files the app needs are fetched: INT8 DiT, DMD2 LoRA, Whisper-Large-v3,
vocal separator, plus the UMT5 text encoder / tokenizer / VAE from LongCat-Video.

Usage:
    python scripts/download_model.py                    # -> ./weights
    WEIGHTS_DIR=/workspace/weights python scripts/download_model.py

snapshot_download skips files that are already complete and resumes partial ones,
so it is safe to re-run after an interrupted download.
"""

import os
from pathlib import Path

from huggingface_hub import snapshot_download


def download_weights(weights_dir: Path) -> None:
    weights_dir = Path(weights_dir)
    token = os.environ.get("HF_TOKEN")

    print("[download] LongCat-Video (vae/text_encoder/tokenizer) ~23 GB…", flush=True)
    snapshot_download(
        "meituan-longcat/LongCat-Video",
        local_dir=str(weights_dir / "LongCat-Video"),
        token=token,
        allow_patterns=[
            "tokenizer/*",
            "text_encoder/*.safetensors",
            "text_encoder/*.json",
            "vae/*.safetensors",
            "vae/*.json",
        ],
        ignore_patterns=[
            "text_encoder/*.fp32*",
            "text_encoder/*.bin",
            "text_encoder/flax_model*",
            "text_encoder/tf_model*",
            "vae/flax_model*",
            "vae/tf_model*",
        ],
    )

    print("[download] LongCat-Video-Avatar-1.5 (INT8 + lora + whisper + vocal_separator) ~22 GB…", flush=True)
    snapshot_download(
        "meituan-longcat/LongCat-Video-Avatar-1.5",
        local_dir=str(weights_dir / "LongCat-Video-Avatar-1.5"),
        token=token,
        allow_patterns=[
            "base_model_int8/*",
            "lora/*",
            "scheduler/*",
            "vocal_separator/*",
            "whisper-large-v3/model.safetensors",
            "whisper-large-v3/*.json",
            "whisper-large-v3/*.txt",
        ],
        ignore_patterns=[
            "whisper-large-v3/model.fp32*",
            "whisper-large-v3/flax_model*",
            "whisper-large-v3/tf_model*",
            "whisper-large-v3/pytorch_model*",
        ],
    )
    print("[download] done", flush=True)


if __name__ == "__main__":
    download_weights(Path(os.environ.get("WEIGHTS_DIR", "weights")))
