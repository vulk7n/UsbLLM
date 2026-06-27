#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)  PLATFORM="linux-x64"  ;;
    aarch64) PLATFORM="linux-arm64" ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

BIN_DIR="$SCRIPT_DIR/bin/$PLATFORM"
LLAMA="$BIN_DIR/llama"
if [ ! -f "$LLAMA" ]; then
    echo "ERROR: $LLAMA not found"
    echo "Make sure the llama binary exists in bin/$PLATFORM/"
    exit 1
fi
if [ ! -x "$LLAMA" ]; then
    chmod +x "$LLAMA" 2>/dev/null || true
    chmod +x "$BIN_DIR"/*.so* 2>/dev/null || true
fi
export LD_LIBRARY_PATH="$BIN_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

for lib in "$BIN_DIR"/*.so.*.*; do
    [ -f "$lib" ] || continue
    base=$(echo "$lib" | sed 's/\.[^.]*\.[^.]*$//')
    if [ ! -e "$base" ]; then
        ln -s "$(basename "$lib")" "$base" 2>/dev/null || true
    fi
done

if [ ! -f "$BIN_DIR/libgomp.so.1" ]; then
    command -v apt-get &>/dev/null && sudo apt-get install -y libgomp1 2>/dev/null || true
fi

MODEL=$(find "$SCRIPT_DIR/models" -name '*.gguf' -print -quit 2>/dev/null || true)
if [ -z "$MODEL" ]; then
    echo "ERROR: No .gguf model found in models/ folder."
    exit 1
fi

if command -v nproc &>/dev/null; then
    THREADS=$(nproc)
elif [ -f /proc/cpuinfo ]; then
    THREADS=$(grep -c ^processor /proc/cpuinfo)
else
    THREADS=4
fi

menu() {
    clear
    echo " _    _     _     _      _      __  __"
    echo "| |  | |   | |   | |    | |    |  \\/  |"
    echo "| |  | |___| |__ | |    | |    | \\  / |"
    echo "| |  | / __| '_ \\| |    | |    | |\\/| |"
    echo "| |__| \\__ \\ |_) | |____| |____| |  | |"
    echo " \\____/|___/_.__/|______|______|_|  |_|"
    echo "        UsbLLM -- Plug and Play"
    echo "========================================"
    echo "Platform : $PLATFORM"
    echo "Model    : $MODEL"
    echo ""
    echo "  1. Terminal Chat  (interactive CLI)"
    echo "  2. Exit"
    echo ""
    read -rp "Select [1-2]: " choice
    case "$choice" in
        1) chat ;;
        2) exit 0 ;;
        *) menu ;;
    esac
}

chat() {
    echo ""
    "$LLAMA" cli \
        -m "$MODEL" \
        --conversation \
        --ctx-size 4096 \
        --temp 0.7 \
        --threads "$THREADS" \
        --mlock
    echo ""
    read -rp "Press Enter to return to menu..."
    menu
}

menu