#!/usr/bin/env bash
# Starts llama-server in router mode: one endpoint for all models in models.ini.
# The requested model is loaded on demand; --models-max 1 keeps only one in VRAM.
LLAMA_DIR="${LLAMA_DIR:-$HOME/llm/llama.cpp}"
exec "$LLAMA_DIR/llama-server" \
  --models-preset "${MODELS_INI:-$HOME/llm/models.ini}" \
  --models-max 1 \
  --host 127.0.0.1 --port 8080 "$@"
