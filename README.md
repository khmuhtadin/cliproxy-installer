# CLIProxy Installer for macOS

Automated installer for **CLIProxyAPIPlus** on macOS. This script simplifies the process of setting up custom AI models (Claude, Gemini, etc.) for use in Droid, Cursor, or other AI-powered editors.

It handles everything from installing dependencies (Go, Git) to configuring the local proxy server.

## 🚀 Features

* **All-in-One Installation**: Automatically checks and installs **Homebrew**, **Git**, and **Go** if they are missing.
* **Auto-Build**: Clones the latest `CLIProxyAPIPlus` repository and builds the binary for your specific architecture (Intel/Apple Silicon).
* **Helper Scripts**: Generates easy-to-use `login.sh` and `start.sh` scripts.
* **Droid Integration**: Automatically injects the necessary model configurations into `~/.factory/config.json` so models appear instantly in Droid.

## 📦 Quick Install

Open your Terminal and run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/khmuhtadin/cliproxy-for-mac/refs/heads/main/install)"
```

## 🛠️ Menu Options

When you run the script, you will see an interactive menu:

1.  **Install Homebrew**: Required package manager.
2.  **Install Git & Go**: Required dependencies.
3.  **Install CLIProxy Only**: If you already have the dependencies.
4.  **FULL INSTALL (Recommended)**: Runs everything in order (1 -\> 2 -\> 3).

## 📖 How to Use

After installation is complete:

### 1\. Login to Providers

Run the login script to authenticate with providers (Antigravity, Copilot, Gemini, etc.):

```bash
~/.cli-proxy-api/scripts/login.sh
```

*Select your preferred provider from the menu and follow the browser instructions.*

### 2\. Start the Proxy

Start the local server. Keep this terminal window open while using Droid/Cursor:

```bash
~/.cli-proxy-api/scripts/start.sh
```

### 3\. Usage in Droid/Cursor

1.  Open Droid.
2.  Go to Model selection.
3.  You will see new models like **"Claude Opus 4.5 Thinking [Antigravity]"** or **"GPT-5 Mini [Copilot]"**.
4.  Select one and start chatting\!

## 📂 File Locations

  * **Binary**: `~/bin/cliproxyapi-plus`
  * **Config**: `~/.cli-proxy-api/config.yaml`
  * **Scripts**: `~/.cli-proxy-api/scripts/`
  * **Droid Config**: `~/.factory/config.json`

## Credits

  * Installer script ported for macOS by [khmuhtadin](https://github.com/khmuhtadin).
  * Core application by [router-for-me/CLIProxyAPIPlus](https://github.com/router-for-me/CLIProxyAPIPlus).

-----

*Disclaimer: This project is for educational purposes only. Please ensure you comply with the terms of service of the respective AI providers.*
