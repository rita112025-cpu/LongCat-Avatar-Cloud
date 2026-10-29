FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    WEIGHTS_DIR=/data/weights \
    HF_HOME=/data/hf_cache \
    GRADIO_SERVER_NAME=0.0.0.0 \
    GRADIO_SERVER_PORT=7860

# build-essential: diffq (pulled in by audio-separator) only ships wheels up
# to cp310, so pip builds it from source and needs a C compiler (gcc).
# Kept in the final image on purpose: Triton / torch.compile may call gcc at
# runtime, so removing it after pip install is not safe.
# Python headers come with the base image's conda Python, so no python3-dev.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg libsndfile1 build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && (python -c "import triton" 2>/dev/null || pip install --no-cache-dir triton==3.1.0)

COPY . .

EXPOSE 7860
VOLUME ["/data"]

# Weights (~45 GB) are downloaded into /data on first start, not baked into the image.
CMD ["python", "app.py"]
