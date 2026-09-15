# LongCat-Video-Avatar 1.5 — 雲端 GPU 版

**照片 + 語音 → 5 秒對嘴說話影片。**

這個 repo 是 Hugging Face 官方 Demo（[meituan-longcat/LongCat-Video-Avatar-1.5-Demo](https://huggingface.co/spaces/meituan-longcat/LongCat-Video-Avatar-1.5-Demo)）的移植版，改成可以在任何雲端 GPU 上跑。

- GitHub 只放程式碼 + 網頁 UI + 範例素材
- 模型（約 45GB）第一次啟動時從 Hugging Face 自動下載
- 手機或電腦瀏覽器打開網址就能用

---

## 硬體需求

| 項目 | 需求 |
| --- | --- |
| GPU | NVIDIA，**建議 80GB VRAM**（A100 80GB / H100）。40–48GB（A100 40GB、L40S、A6000）可能可跑，尚未驗證 |
| 磁碟 | 至少 **60GB** 空間（模型 45GB + 快取） |
| RAM | 建議 64GB 以上（模型先載入 RAM 再搬到 GPU） |
| 系統 | Linux（Colab / RunPod / 雲端 VM）。**不支援一般 Windows 電腦直接跑** |

> GitHub 本身沒有 GPU，不能直接執行。一定要搭配下面其中一種雲端 GPU。

---

## 三種跑法（由簡單到進階）

### A. Google Colab（最快測試，約 20–40 分鐘可看到畫面）

需要 Colab Pro 或運算單元（才能選 A100）。

1. 點這裡開啟 notebook：[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/rita112025-cpu/LongCat-Avatar-Cloud/blob/main/notebooks/colab_quickstart.ipynb)
2. 執行階段 → 變更執行階段類型 → **A100 GPU** + 高 RAM
3. 依序執行 3 個儲存格
4. 打開最後印出的 `https://xxxx.gradio.live` 連結

### B. RunPod / 任何 Linux GPU 主機（最推薦長期測試）

1. 在 RunPod 建立 Pod：
   - 範本：**RunPod PyTorch**（CUDA 12.x）
   - GPU：A100 80GB 或 H100
   - Volume Disk：**80GB**，掛載在 `/workspace`
   - HTTP Port：**7860**
2. 開啟 Pod 的 Web Terminal，執行：

   ```bash
   cd /workspace && git clone https://github.com/rita112025-cpu/LongCat-Avatar-Cloud && cd LongCat-Avatar-Cloud && bash scripts/start_cloud.sh
   ```

3. 看到 `[boot] ready.` 後，點 RunPod 介面上的 **Connect → HTTP 7860**

模型存在 `/workspace/weights`，Pod 重開不會重新下載。不用時記得 **Stop Pod**，否則會一直計費。

### C. Docker（自己的 GPU 主機 / 雲端 VM）

主機需要已安裝 NVIDIA driver + [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)。

```bash
git clone https://github.com/rita112025-cpu/LongCat-Avatar-Cloud && cd LongCat-Avatar-Cloud && docker compose up -d --build
```

然後打開 `http://<主機IP>:7860`。模型存在 `./data/weights`。

也可以直接用 GitHub Actions 自動建好的映像檔（push 到 `main` 後自動產生）：

```text
ghcr.io/rita112025-cpu/longcat-avatar-cloud:latest
```

> GHCR 套件預設是私人的。要給 RunPod 等平台拉取，請到 GitHub → Packages → 該套件 → Package settings 改成 Public，或在平台上設定 registry 登入。

---

## 使用方式

1. 上傳人物照片（或點範例）
2. 上傳語音（WAV / MP3）
3. 輸入描述（英文效果較好），例如 `A person is talking naturally to the camera.`
4. 按生成 → 等待 → 預覽 / 下載 MP4

| 選項 | 說明 |
| --- | --- |
| Resolution | `480p` 較快；`720p` 較清晰、較吃 VRAM |
| Vocal mode | `Clean speech (fast)`：乾淨人聲直接用；`Isolate vocals (quality)`：有背景音樂時先分離人聲 |
| Acceleration | `DBCache faster` 最快；`Exact 8-step` 品質最穩 |

目前固定輸出 125 frames（25 FPS，5 秒）。

---

## 環境變數

| 變數 | 預設 | 用途 |
| --- | --- | --- |
| `WEIGHTS_DIR` | `weights` | 模型下載位置 |
| `HF_TOKEN` | 無 | Hugging Face token（模型公開，一般不需要） |
| `GRADIO_SERVER_PORT` | `7860` | 網頁埠號 |
| `GRADIO_SHARE` | 無 | 設 `1` 產生公開 `gradio.live` 連結 |
| `LONGCAT_SKIP_DOWNLOAD` | 無 | 設 `1` 跳過下載檢查（完全離線啟動） |

只想先下載模型：

```bash
WEIGHTS_DIR=/workspace/weights python scripts/download_model.py
```

---

## 和原版 HF Space 的差異

- 模型下載移到 `scripts/download_model.py`，中斷後重跑會續傳
- 不需要 `spaces`（ZeroGPU 專用）與 `xformers`，注意力改走 PyTorch SDPA（原版 Space 也是這樣做）
- 預設監聽 `0.0.0.0:7860`，雲端主機可直接連
- 新增 Dockerfile、docker-compose、RunPod 啟動腳本、Colab notebook、GHCR 自動建置

---

## 來源與授權

- 原始 Demo：https://huggingface.co/spaces/meituan-longcat/LongCat-Video-Avatar-1.5-Demo
- 官方程式碼：https://github.com/meituan-longcat/LongCat-Video
- 模型權重：https://huggingface.co/meituan-longcat/LongCat-Video-Avatar-1.5

程式碼與模型的授權條款以上述官方頁面為準。
