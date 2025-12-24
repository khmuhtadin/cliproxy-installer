# CLIProxy Installer for macOS, Linux & Windows

Automated installer for **CLIProxyAPIPlus**. This script simplifies the process of setting up custom AI models (Claude, Gemini, etc.) for use in Droid, Cursor, Claude Code, or other AI-powered editors.

## Features

* **Cross-Platform**: One script works on **macOS**, **Linux**, and **Windows (Git Bash)**.
* **Auto-Detect OS**: Automatically detects your platform and optimizes installation.
* **Smart Config Merge**: Intelligently adds new models to your `config.json` without overwriting custom configurations.
* **Auto-Update**: Built-in self-updater keeps both the installer and the core CLIProxy binary up to date.
* **Helper Scripts**: Easy aliases (`cp-login`, `cp-start`, `cp-claude`, `cp-db`) for your terminal.
* **Dashboard**: Real-time quota monitoring with tab-based interface.
* **Quota Fetcher**: Auto-refresh quota data every 10 minutes via cron job.

## Quick Install (Universal)

Copy and run this single command in your terminal (**macOS Terminal**, **Linux Bash**, or **Windows Git Bash**):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/khmuhtadin/cliproxy-installer/main/install)"
```

### Installation Notes
* **macOS**: Installs dependencies via Homebrew.
* **Linux**: Installs via `apt`, `dnf`, `pacman`, `zypper`, or `yum`.
* **Windows**: Run this inside **Git Bash**. Please ensure you have [Git](https://git-scm.com/download/win) and [Go](https://go.dev/dl/) installed.

### Optional Components
During installation, you can optionally install:
* **[Claude Statusline](https://github.com/galpratama/claude-statusline)**: Displays AI model info, costs, and git status in Claude Code.
* **[Superpowers](https://github.com/obra/superpowers)**: Advanced workflow skills for Claude Code (brainstorming, planning, TDD).

## Dashboard

The installer includes an Antigravity Dashboard for monitoring accounts and quota.

```bash
# Open dashboard (auto-starts server if needed)
cp-db
```

Or visit: `http://localhost:8317/dashboard.html`

### Dashboard Features
* **Dashboard Tab**: Overview stats + aggregated quota from all accounts
* **Usage History Tab**: Real-time usage statistics per model
* **Accounts Tab**: Manage authenticated accounts with quota details

### Quota Auto-Refresh
The installer sets up a cron job to refresh quota data every 10 minutes:
```bash
# Manual refresh
python3 ~/.cli-proxy-api/scripts/quota-fetcher.py
```

## How to Use

After installation, **restart your terminal** or run `source ~/.zshrc` (or `~/.bashrc`).

### 1. Login to Providers
```bash
cp-login
```
Supported providers:
1. Antigravity (Claude/Gemini)
2. GitHub Copilot
3. Gemini CLI
4. Codex
5. Claude
6. Qwen
7. iFlow
8. Kiro

### 2. Start Proxy
```bash
cp-start
```

### 3. Stop Proxy
```bash
cp-stop
```

### 4. Claude Code Integration
```bash
# Interactive model selection
cp-claude
```

### 5. Update Everything
```bash
cp-update
```
Updates: Claude Code, CLIProxy Core, Statusline, Dashboard, Superpowers.

## Shortcuts Reference

| Command | Description |
|---------|-------------|
| `cp-login` | Open login menu for providers |
| `cp-start` | Start proxy server on port 8317 |
| `cp-stop` | Stop proxy server |
| `cp-update` | Update all components |
| `cp-db` | Open Antigravity Dashboard |
| `cp-claude` | Run Claude Code with proxy |

## File Locations

| Platform | Binary | Config | Scripts | Dashboard |
|----------|--------|--------|---------|-----------|
| **macOS/Linux** | `~/bin/cliproxyapi-plus` | `~/.cli-proxy-api/config.yaml` | `~/.cli-proxy-api/scripts/` | `~/.cli-proxy-api/static/` |
| **Windows** | `~/bin/cliproxyapi-plus.exe` | `~/.cli-proxy-api/config.yaml` | `~/.cli-proxy-api/scripts/` | `~/.cli-proxy-api/static/` |

## Troubleshooting

### Dashboard shows 0% quota
Run the quota fetcher manually:
```bash
python3 ~/.cli-proxy-api/scripts/quota-fetcher.py
```

### cp-update not found
Restart your terminal or run:
```bash
source ~/.zshrc  # or ~/.bashrc
```

### Account shows 403 error
Re-login to the provider:
```bash
cp-login
```

## Credits

* Installer maintained by [khmuhtadin](https://github.com/khmuhtadin).
* Core app by [router-for-me/CLIProxyAPIPlus](https://github.com/router-for-me/CLIProxyAPIPlus).
* Claude Statusline by [galpratama/claude-statusline](https://github.com/galpratama/claude-statusline).
* Superpowers by [Jesse Vincent (obra)](https://github.com/obra/superpowers).
