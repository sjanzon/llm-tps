[English](README.md) · **Deutsch**

# llm-tps

Ein Live-Dashboard im Terminal für einen lokalen **llama.cpp-Router** (`llama-server` im Router-Modus mit mehreren Modellen). Es zeigt die Token pro Sekunde während der Generierung und führt ein Verlaufsdiagramm mit einer Farbe pro Modell. Dazu kommen Kontext- und Prompt-Cache-Auslastung, GPU, VRAM, Leistung, RAM und CPU, Statistiken je Modell sowie Lade- und Entlade-Ereignisse.

Es ist eine einzige Python-Datei, die nur die Standardbibliothek braucht.

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

Die Oberfläche des Programms ist englisch.

## Funktionen

- **Live-Status**:
  - Welches Modell geladen ist und in welchem Zustand: bereit, lädt, liest den Prompt ein oder generiert mit aktuellen tok/s.
  - Wie lange das Modell schon geladen ist.
- **Messbalken**:
  - Kontext-Füllstand, während einer Anfrage mit dem Anteil, der aus dem Prompt-Cache kommt.
  - GPU-Auslastung und Temperatur, VRAM sowie Leistungsaufnahme im Verhältnis zum Power-Limit, dazu die verbrauchte Energie.
  - System-RAM und der RAM der llama-Prozesse.
  - Von llama genutzte CPU-Threads. Das ist bei MoE-Modellen wichtig, deren Experten in den RAM ausgelagert sind.
- **Verlaufsdiagramm**:
  - Eine Spalte pro Sekunde, eine Farbe pro Modell.
  - Prompt-Einlesen und Modell-Laden sind eigens markiert.
  - Das Zeitfenster lässt sich auf 1, 5, 15 oder 60 Minuten umschalten.
- **Statistik je Modell** (wird beim Start aus dem heutigen Log rekonstruiert):
  - Anzahl der Antworten.
  - Durchschnittliche und letzte Ausgabegeschwindigkeit.
  - Prompt-Geschwindigkeit und Median der Zeit bis zum ersten Token (TTFT).
  - Trefferquote des Prompt-Cache.
  - Trefferquote von MTP bzw. Speculative Decoding.
  - Ausgabe-Token heute und Wh pro 1000 Token.
- **Tempo nach Kontextlänge**: Ausgabe-tok/s bei Kontexten unter 16k, 16–64k und über 64k. Zeigt, wie stark ein Modell bei langem Kontext langsamer wird.
- **Ereignisse**: Modellwechsel, Laden mit Dauer, Entladen mit Exit-Code, Dienst-Neustarts und jede abgeschlossene Antwort.
- **Layout**:
  - Passt sich der Terminalgröße an: Messbalken ab 100 Spalten zweispaltig.
  - Das Log behält immer mindestens ein Drittel der Höhe.
  - Drei Ansichten: alles, Log und Diagramm.
  - Neu gezeichnet wird nur, wenn sich etwas geändert hat.

## Voraussetzungen

- Linux mit **Python 3.8+**. Es wird nur die Standardbibliothek verwendet.
- **llama.cpp** mit Router-Modus (`llama-server --models-preset …`, ein aktueller Build).
- Der Router läuft als **systemd-User-Dienst**. llm-tps liest dessen Log über `journalctl --user`.
- Optional: **NVIDIA-GPU** mit `nvidia-smi` für die Balken GPU, VRAM und Leistung. Ohne sie werden diese Balken ausgeblendet.

## Installation

```bash
git clone https://github.com/sjanzon/llm-tps.git
install -m 755 llm-tps/llm-tps ~/.local/bin/llm-tps
```

Falls der Router noch nicht als Dienst läuft, findest du im Ordner `examples/` eine Vorlage:

| Datei | Zweck |
|---|---|
| `examples/models.ini` | Router-Presets für drei Modelle: Pfade, Kontextgröße, MTP, Sampling |
| `examples/start-llm.sh` | Startet `llama-server` im Router-Modus, immer ein Modell im VRAM |
| `examples/llama-router.service` | systemd-User-Unit |

```bash
mkdir -p ~/llm ~/.config/systemd/user
cp examples/models.ini examples/start-llm.sh ~/llm/           # danach Modellpfade anpassen
cp examples/llama-router.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user start llama-router
```

## Benutzung

```bash
llm-tps                 # Dashboard
llm-tps --plain         # reiner Text: eine Zeile pro Ereignis plus Live-Statuszeile
llm-tps -n 20           # die letzten 20 Antworten/Ereignisse aus dem heutigen Log, dann Ende
llm-tps --unit mein-llm # anderer Name der systemd-Unit
llm-tps --server http://127.0.0.1:9000
```

| Taste | Funktion |
|---|---|
| `q` | Beenden |
| `p` | Anzeige pausieren / fortsetzen (Daten werden weiter gesammelt) |
| `v` | Ansicht wechseln: **all** → **log** (Kopf + langes Log) → **chart** (großes Diagramm + Tabellen) |
| `1` `2` `3` `4` | Zeitfenster des Diagramms: 1 / 5 / 15 / 60 Minuten |
| `a` | Zeitfenster automatisch (1 Sekunde pro Spalte) |
| `c` | Statistik zurücksetzen |

### Konfiguration

| Option | Umgebungsvariable | Standard |
|---|---|---|
| `--server` | `LLM_TPS_SERVER` | `http://127.0.0.1:8080` |
| `--unit` | `LLM_TPS_UNIT` | `llama-router` |

## Funktionsweise

- **Live-Werte**: Viermal pro Sekunde über die Router-API.
  - `GET /models` liefert den Ladezustand aller Modelle.
  - `GET /slots?model=…&autoload=false` liefert die bisher erzeugten Token, den Kontext und den Cache der laufenden Anfrage.
  - `autoload=false` ist dabei wichtig: Ohne diesen Parameter würde die Abfrage ein gerade entladenes Modell wieder laden.
- **Abgeschlossene Antworten und Ereignisse**: Werden aus dem Router-Log gelesen (`journalctl --user -u <unit> -f`). Eine Antwort gilt mit ihrer `release`-Zeile als abgeschlossen, die nach den Prompt-, Ausgabe- und MTP-Werten kommt.
- **Systemwerte**: Einmal pro Sekunde aus `nvidia-smi` und `/proc`.

## Einschränkungen

- Energie und Wh/1k werden nur gezählt, solange llm-tps läuft. Die übrigen Statistiken werden aus dem heutigen Log rekonstruiert.
- Den Kontext-Füllstand meldet der Router nur während einer Anfrage. Direkt nach dem Start zeigt der Balken deshalb `0.0k`, bis die erste Anfrage kommt.
- Ob das Modell gerade „denkt“ oder antwortet, ist über die API nicht erkennbar. Beides zählt als erzeugte Token.
- Ausgelegt auf einen Slot pro Modell (`parallel = 1`), wie für einen einzelnen Agenten üblich.
- Die GPU-Werte gibt es nur für NVIDIA.
