# CLIProxy Installer for macOS, Linux & Windows

Automated installer for **CLIProxyAPIPlus**. This script simplifies the process of setting up custom AI models (Claude, Gemini, etc.) for use in Droid, Cursor, or other AI-powered editors.

## Features

* **Cross-Platform**: One script works on **macOS**, **Linux**, and **Windows (Git Bash)**.
* **Auto-Detect OS**: Automatically detects your platform and optimizes installation.
* **Smart Config Merge**: Intelligently adds new models to your `config.json` without overwriting custom configurations.
* **Auto-Update**: Built-in self-updater keeps both the installer and the core CLIProxy binary up to date.
* **Helper Scripts**: Easy aliases (`cp-login`, `cp-start`, `cp-claude`) for your terminal.

## Quick Install (Universal)

Copy and run this single command in your terminal (**macOS Terminal**, **Linux Bash**, or **Windows Git Bash**):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/khmuhtadin/cliproxy-installer/main/install)"
```

### Installation Notes
*   **macOS**: Installs dependencies via Homebrew.
*   **Linux**: Installs via `apt`, `dnf`, `pacman`, etc.
*   **Windows**: Run this inside **Git Bash**. Please ensure you have [Git](https://git-scm.com/download/win) and [Go](https://go.dev/dl/) installed.

## Dashboard

The installer includes a management dashboard.

```bash
# Open dashboard (auto-starts server if needed)
cp-db
```

Or visit: `http://localhost:8317/dashboard.html`

## How to Use

After installation, **restart your terminal**.

### 1. Login to Providers
```bash
cp-login
```

### 2. Start Proxy
```bash
cp-start
```

### 3. Claude Code Integration
```bash
# Interactive model selection
cp-claude
```

## Shortcuts Reference
* `cp-login` : Open login menu.
* `cp-start` : Start proxy server.
* `cp-stop`  : Stop proxy server.
* `cp-update`: Update everything.
* `cp-db`    : Open dashboard.
* `cp-claude`: Run Claude Code with proxy.

## File Locations
| Platform | Binary | Config | Scripts | 
| :--- | :--- | :--- | :--- |
| **macOS/Linux** | `~/bin/cliproxyapi-plus` | `~/.cli-proxy-api/config.yaml` | `~/.cli-proxy-api/scripts/` |
| **Windows** | `~/bin/cliproxyapi-plus.exe` | `~/.cli-proxy-api/config.yaml` | `~/.cli-proxy-api/scripts/` |

## Credits
* Installer maintained by [khmuhtadin](https://github.com/khmuhtadin).
* Core app by [router-for-me/CLIProxyAPIPlus](https://github.com/router-for-me/CLIProxyAPIPlus).
* Claude Statusline by [galpratama/claude-statusline](https://github.com/galpratama/claude-statusline).
