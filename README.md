# <div align="center">
  <pre>
 _    _     _     _      _      __  __
| |  | |   | |   | |    | |    |  \/  |
| |  | |___| |__ | |    | |    | \  / |
| |  | / __| '_ \| |    | |    | |\/| |
| |__| \__ \ |_) | |____| |____| |  | |
 \____/|___/_.__/|______|______|_|  |_|</pre>
  **UsbLLM — Plug and Play**
</div>

A zero-dependency, portable LLM runtime powered by [llama.cpp](https://github.com/ggerganov/llama.cpp). Drop it on a USB drive, carry it anywhere, and run a local LLM on any Windows or Linux machine — no Python, no pip, no Conda, no CUDA, no internet required.

---

## Features

- **Fully Portable** — Single folder, no installers, no system-wide dependencies. Works from a USB drive.
- **Cross-Platform** — Windows (x64 & ARM64) and Linux (x86_64) binaries included.
- **Plug & Play** — Drop a `.gguf` model into the `models/` folder and run `LLM.bat` (Windows) or `LLM.sh` (Linux).
- **Two Interfaces**
  - **Terminal Chat** — Interactive conversational CLI with conversation history.
- **Hardware Optimized** — Auto-detects CPU core count, uses mlock for RAM residency, multi-threaded inference.
- **Configurable** — Adjust context size, temperature, max tokens, GPU offloading, and port via `config.json`.

---

## Quick Start

### Windows

Double-click `LLM.bat` or run from a terminal:

```cmd
LLM.bat
```

The launcher will:
1. Auto-detect x64 or ARM64 architecture
2. Install the VC++ Redistributable if missing
3. Find the first `.gguf` model in `models/`
4. Show an interactive menu

### Linux

```bash
chmod +x LLM.sh
./LLM.sh
```

The launcher will:
1. Auto-detect x86_64 or aarch64 architecture
2. Install `libgomp1` if missing (requires `apt-get`)
3. Find the first `.gguf` model in `models/`
4. Show an interactive menu

### Menu Options

| Option | Description |
|--------|-------------|
| **1. Terminal Chat** | Opens an interactive conversational CLI |
| **2. Exit** | Exits the launcher |

---

## Configuring the Model

### Included Model

This release ships with a pre-downloaded GGUF model in `models/model.gguf` (~2.39 GB). Check the [Releases](https://github.com/USERNAME/REPO/releases) page for details on which model is bundled.

### Adding Your Own Model

1. Download any GGUF-format model (e.g., from [Hugging Face](https://huggingface.co/models?library=gguf) or [TheBloke](https://huggingface.co/TheBloke)).
2. Place the `.gguf` file into the `models/` folder.
3. Ensure only **one** `.gguf` file is present in `models/`, or the launcher will use the first one found.

**Recommended models** (sorted by size, smallest first):

| Model | Size (Q4_K_M) | Notes |
|-------|---------------|-------|
| [Llama-3.2-1B-Instruct](https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF) | ~0.8 GB | Fast, great for low-resource machines |
| [Llama-3.2-3B-Instruct](https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF) | ~2.0 GB | Good balance of speed and quality |
| [Llama-3.1-8B-Instruct](https://huggingface.co/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF) | ~4.9 GB | Best quality. Requires ~6 GB RAM |
| [Qwen2.5-7B-Instruct](https://huggingface.co/Qwen/Qwen2.5-7B-Instruct-GGUF) | ~4.5 GB | Strong multilingual support |
| [Mistral-7B-Instruct](https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF) | ~4.1 GB | Fast 7B-class model |

> **Tip**: Use `Q4_K_M` quantization for the best quality-to-size ratio.

---

## Configuration

Edit `config.json` to change runtime defaults:

```json
{
  "port": 8080,
  "threads": 0,
  "ctx_size": 4096,
  "gpu_layers": 0,
  "temperature": 0.7,
  "max_tokens": 2048,
  "mlock": true
}
```

| Field | Default | Description |
|-------|---------|-------------|
| `port` | `8080` | Reserved for future Web UI server port |
| `threads` | `0` | CPU threads (`0` = auto-detect) |
| `ctx_size` | `4096` | Context window size (tokens) |
| `gpu_layers` | `0` | Layers to offload to GPU (`0` = CPU only). Requires a compatible build |
| `temperature` | `0.7` | Sampling temperature (higher = more creative) |
| `max_tokens` | `2048` | Maximum tokens per response |
| `mlock` | `true` | Lock model in RAM to prevent swapping |

> **Note**: `config.json` is read by the launcher scripts and passed as flags to the llama binary. The launcher currently passes `--ctx-size`, `--temp`, `--threads`, and `--mlock` from config. GPU layers support requires a CUDA/Metal-enabled build (not included in this portable release by default).

---

## Directory Structure

```
USBLLM/
├── LLM.bat           # Windows launcher
├── LLM.sh            # Linux launcher
├── config.json       # Runtime configuration
├── README.md
├── models/
│   └── model.gguf    # GGUF model file (add your own here)
├── bin/
│   ├── win-x64/      # Windows x64 llama.cpp binaries
│   ├── win-arm64/    # Windows ARM64 llama.cpp binaries
│   └── linux-x64/    # Linux x86_64 llama.cpp binaries
└── redist/
    ├── vc_redist.x64.exe      # VC++ Redist for x64 Windows
    └── vc_redist.arm64.exe    # VC++ Redist for ARM64 Windows
```

---

## Building Your Own Portable Bundle

1. Download or build [llama.cpp](https://github.com/ggerganov/llama.cpp) for your target platforms.
2. Copy the binaries into `bin/<platform>/`:
   - `llama` / `llama.exe` — main binary with `cli` and `serve` subcommands
   - Supporting `.dll` / `.so` files as needed
3. Place a `.gguf` model in `models/`.
4. Distribute the folder.

---

## FAQ

**Q: How do I use a different model?**
A: Remove or rename the existing `.gguf` in `models/`, add your new one, and restart the launcher.

**Q: Can I run this on macOS?**
A: Not yet — macOS binaries are not included. You can build from source using the llama.cpp repo.

**Q: How do I enable GPU acceleration?**
A: Download or build a GPU-enabled version of llama.cpp (CUDA for NVIDIA, Metal for Apple, Vulkan for cross-platform). Replace the binaries in `bin/` with your GPU-enabled build and set `gpu_layers` in `config.json`.

**Q: What if I see "No .gguf model found"?**
A: Ensure your model file has a `.gguf` extension and is placed directly in the `models/` folder (not in a subdirectory).

**Q: Can I run the llama binary directly without the menu?**
A: Yes. For example:
```cmd
bin\win-x64\llama.exe cli -m models\model.gguf --conversation
```

---

## License

This project bundles [llama.cpp](https://github.com/ggerganov/llama.cpp), which is MIT licensed. The included model is subject to its own license (typically Apache 2.0, CC-BY-NC, or Llama Community License). Check the model source for specific terms.

```
UsbLLM — llama.cpp based LLM launcher
Copyright (c) 2024

Licensed under the MIT License.
```