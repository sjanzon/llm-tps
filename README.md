**English** · [Deutsch](README.de.md)

# llm-tps

A live terminal dashboard for a local **llama.cpp router** (`llama-server` in router mode with several models). It shows tokens per second while the model is generating and keeps a history chart with one color per model. It also tracks context and prompt cache usage, GPU, VRAM, power, RAM and CPU, per-model statistics, and model load and unload events.

It is a single Python file with no dependencies beyond the standard library.

```
llm-tps · qwen3.8-27b · ⏳ generating  122 tok @ 96.5 tok/s  (loaded for 23 min)
Context  ████░░░░░░░░░░░░░░░ cache  99% · 25.6k/131k  20% │ Power    ██████████████░░░░░ 320/450 W · Σ 0.0 Wh
GPU      ███████████████████ 53 °C ·  98%                 │ VRAM     ██████████████████░ 23.3/24.0 GB
RAM      ██░░░░░░░░░░░░░░░░░ llama 3.5 · 5.0/60 GB        │ CPU      █░░░░░░░░░░░░░░░░░░ 1.0/32 threads   3%
──────────────────────────────────────────────────────────┴──────────────────────────────────────────────────────────
  125 ┤                                                                               ▆▃               ▃
   62 ┤                                                                    ▇█▅▆   ▃█████▇▅        ▃█
      ┤                                                                ▃▃▃▃████████████████▃     ▃██
tok/s └─────────────────────────────────────────────────────────────────────────────────────────────────────────────
      -2 min (auto)                                                                                             now
      █ devstral-small-2   █ qwen3.6-35b-a3b   █ qwen3.8-27b   ▃ prompt   ▃ loading
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
Model               Answ.    Ø output       last   Ø prompt  Ø TTFT  Cache   MTP   Out today  Wh/1k
  devstral-small-2      6    50.8 t/s   49.5 t/s   3577 t/s   0.2 s    73%     –         987      –
  qwen3.6-35b-a3b       8   191.4 t/s  180.6 t/s   1671 t/s   0.4 s    83%   89%        6.9k      –
● qwen3.8-27b          48    81.5 t/s   87.6 t/s   2206 t/s   0.2 s    94%   70%       35.3k   0.47
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
Output speed by context        <16k    16–64k      >64k
  devstral-small-2         50.8 t/s         –         –
  qwen3.6-35b-a3b         191.4 t/s         –         –
● qwen3.8-27b             112.6 t/s  80.9 t/s  63.3 t/s
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
Events & answers
22:35:23  ⇄ model switch: unloading devstral-small-2
22:35:23  ■ devstral-small-2 unloaded
22:35:23  ▶ loading qwen3.8-27b …
22:35:29  ● qwen3.8-27b loaded in 6 s
22:41:27  ✔ qwen3.8-27b:   225 tok @  87.3 t/s  TTFT  8.9 s  context  25.6k  cache   0 %  MTP  59 %
22:41:30  ✔ qwen3.8-27b:   226 tok @  92.2 t/s  TTFT  0.1 s  context  25.6k  cache 100 %  MTP  64 %
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
q quit · p pause · v view: all · 1/2/3/4 window 1/5/15/60 min · a auto · c reset stats
```

## Features

- **Live status**:
  - The model that is currently loaded and its state: ready, loading, processing the prompt, or generating at the current tok/s.
  - How long the model has been loaded.
- **Meters**:
  - Context fill level, with the share of the prompt served from the cache during a request.
  - GPU utilization and temperature, VRAM, and power draw against the power limit, plus the energy used.
  - System RAM and the RAM used by the llama processes.
  - CPU threads used by llama. This matters for MoE models whose experts are offloaded to RAM.
- **History chart**:
  - One column per second, one color per model.
  - Prompt processing and model loading are marked separately.
  - Time window can be switched between 1, 5, 15 and 60 minutes.
- **Per-model statistics** (rebuilt from today's log when the tool starts):
  - Number of answers.
  - Average and last output speed.
  - Prompt speed and median time to first token (TTFT).
  - Prompt cache hit rate.
  - MTP / speculative decoding acceptance.
  - Output tokens today and Wh per 1000 tokens.
- **Speed by context length**: output tok/s for contexts under 16k, 16–64k and over 64k. This shows how much a model slows down on long contexts.
- **Events**: model switches, loading with its duration, unloading with the exit code, service restarts, and every finished answer.
- **Layout**:
  - Adapts to the terminal size: meters in two columns from 100 columns on.
  - The log always keeps at least a third of the height.
  - Three views: all, log and chart.
  - Redraws only when something changed.

## Requirements

- Linux with **Python 3.8+**. Only the standard library is used.
- **llama.cpp** with router mode (`llama-server --models-preset …`, a recent build).
- The router runs as a **systemd user service**. llm-tps reads its log with `journalctl --user`.
- Optional: **NVIDIA GPU** with `nvidia-smi` for the GPU, VRAM and power meters. Without it, those meters are hidden.

## Installation

```bash
git clone https://github.com/sjanzon/llm-tps.git
install -m 755 llm-tps/llm-tps ~/.local/bin/llm-tps
```

If you don't run the router as a service yet, the `examples/` folder has a starting point:

| File | Purpose |
|---|---|
| `examples/models.ini` | Router presets for three models: paths, context size, MTP, sampling |
| `examples/start-llm.sh` | Starts `llama-server` in router mode, one model in VRAM at a time |
| `examples/llama-router.service` | systemd user unit |

```bash
mkdir -p ~/llm ~/.config/systemd/user
cp examples/models.ini examples/start-llm.sh ~/llm/           # then edit the model paths
cp examples/llama-router.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user start llama-router
```

## Usage

```bash
llm-tps                 # dashboard
llm-tps --plain         # plain text: one line per event plus a live status line
llm-tps -n 20           # last 20 answers/events from today's log, then exit
llm-tps --unit my-llm   # different systemd unit name
llm-tps --server http://127.0.0.1:9000
```

| Key | Action |
|---|---|
| `q` | quit |
| `p` | pause / resume the display (data is still collected) |
| `v` | switch the view: **all** → **log** (header + long log) → **chart** (large chart + tables) |
| `1` `2` `3` `4` | chart window 1 / 5 / 15 / 60 minutes |
| `a` | automatic chart window (1 second per column) |
| `c` | reset statistics |

### Configuration

| Option | Environment variable | Default |
|---|---|---|
| `--server` | `LLM_TPS_SERVER` | `http://127.0.0.1:8080` |
| `--unit` | `LLM_TPS_UNIT` | `llama-router` |

## How it works

- **Live values**: polled four times per second from the router API.
  - `GET /models` gives the load state of all models.
  - `GET /slots?model=…&autoload=false` gives tokens generated so far, context and cache for the running request.
  - `autoload=false` matters: without it, the poll would reload a model the router just unloaded.
- **Finished answers and events**: parsed from the router log (`journalctl --user -u <unit> -f`). An answer is complete once its `release` line appears, after the prompt, generation and MTP timings.
- **System values**: read once per second from `nvidia-smi` and `/proc`.

## Limitations

- Energy and Wh/1k are counted only while llm-tps is running. The other statistics are rebuilt from today's log.
- The router reports the context fill level only during a request. Right after start, the context bar shows `0.0k` until the first request.
- The API does not reveal whether the model is currently "thinking" or answering. Both count as generated tokens.
- Built for one slot per model (`parallel = 1`), the usual setup for a single-user agent.
- GPU meters are NVIDIA only.

## License

Copyright (C) 2026 Sven Janzon. Licensed under the [GNU General Public License v3.0 or later](LICENSE). You may use, change and share llm-tps; modified versions you distribute must stay under the GPL and include their source code.
