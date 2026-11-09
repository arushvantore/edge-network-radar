# 🛰️ Edge Network Radar (ENR)

![License: MIT](https://img.shields.io/badge/License-MIT-Blue.svg)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker&logoColor=white)
![Status](https://img.shields.io/badge/Status-Production_Ready-BrightGreen)
![Runtime](https://img.shields.io/badge/Runtime-Edge_Computing-FF6B35)

## 🧠 Overview

**Edge Network Radar** is a production-grade **containerized edge-computing network daemon** that continuously issues ARP (Address Resolution Protocol) sweeps across the local network segment and pipelines the resulting probe telemetry into a **local LLM orchestration middleware layer** for real-time anomaly interpretation and autonomous network operations.

Built for AI & Cloud Computing research, security telemetry pipelines, and edge infrastructure teams, the daemon converts raw layer-2 neighbor-discovery data into actionable, LLM-orchestrated observability insights — running entirely on local infrastructure.

## 🏗️ Architecture

```
[ Edge Probe ] --arp-scan--> [ Telemetry Buffer ] --scan.log--> [ LLM Orchestrator ] --LLM inference--> [ Local Store ]
     |                                |                             |                            |
     v                                v                             v                            v
 Docker Container          ~/radar-logs/scan.log        local LLM (Ollama-backed     persistent telemetry store
 (network-radar-service)     (timestamped metrics)       orchestration middleware      (~/radar-logs/)
```

1. **Edge Probe** — A hardened `debian:bookworm-slim` container executing `arp-scan -I <iface> <subnet>` under host networking with privileged packet access.
2. **Telemetry Buffer** — Timestamped probe output is streamed into a persistent local log store.
3. **LLM Orchestration Middleware** — Scan metrics feed a local LLM orchestration layer that evaluates probe patterns and drives follow-on orchestration workflows.

## ✨ Features

- **One-shot deployment** — `./radar.sh` builds and launches the full stack in a single command.
- **Continuous ARP probing** — Periodic neighbor-discovery sweeps with persistent telemetry.
- **LLM orchestration** — Raw scan metrics piped into a local LLM middleware for anomaly analysis.
- **Persistent telemetry** — Bind-mounted volume store at `~/radar-logs/scan.log`.
- **Self-healing runtime** — `--restart always` policy on all managed containers.

## 🚀 Quick Start

```bash
git clone https://github.com/arushvantore/edge-network-radar.git
cd edge-network-radar
./radar.sh
```

The master deployment script will:

1. Install `arp-scan` via Homebrew (host dependency).
2. Generate the radar Docker image (`network-radar-service`).
3. Start the probe daemon container.
4. Start the Open WebUI orchestration frontend.

Then open:

```
http://localhost:3000
```

## 📄 Telemetry Output

Each line emitted to `~/radar-logs/scan.log`:

```
<YYYY-MM-DD HH:MM:SS> | <arp-scan probe output>
```

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Containerization | Docker (`--network host`, `--privileged`) |
| Probe Engine | `arp-scan`, `iproute2` |
| Base Image | `debian:bookworm-slim` |
| Automation | Bash one-shot deployment script |
| Orchestration | Open WebUI (local) |

## 🔒 Security Notes

Containers operate in **privileged** mode with **host networking** on the local edge gateway. In production deployments, replace with least-privilege capabilities and managed network policies.

## 📜 License

Distributed under the MIT License.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome via GitHub Issues and PRs.

---

<p align="center">Built by <a href="https://github.com/arushvantore">@arushvantore</a> — AI & Cloud Computing</p>
