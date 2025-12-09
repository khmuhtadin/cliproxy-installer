# CLIProxy Installer for macOS & Linux

Automated installer for **CLIProxyAPIPlus**. This script simplifies the process of setting up custom AI models (Claude, Gemini, etc.) for use in Droid, Cursor, or other AI-powered editors.

It handles everything from installing dependencies (Go, Git), configuring the local proxy server, to managing updates.

## 🚀 Features

* **All-in-One Installation**: Automatically checks and installs **Homebrew** (macOS) or relevant package managers (Linux), **Git**, and **Go** if they are missing.
* **Smart Config Merge**: Intelligently adds new models to your `config.json` without overwriting your existing custom configurations.
* **Auto-Update**: Built-in self-updater keeps both the installer and the core CLIProxy binary up to date with a single command.
* **Auto-Build**: Clones the latest `CLIProxyAPIPlus` repository and builds the binary for your specific architecture (Intel/Apple Silicon).
* **Helper Scripts & Shortcuts**: Generates easy-to-use aliases (`cp-login`, `cp-start`, `cp-update`) for your terminal.
* **Droid Integration**: Automatically injects the necessary model configurations into `~/.factory/config.json` so models appear instantly in Droid.

## 📦 Quick Install for macOS

Open your Terminal and run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/khmuhtadin/cliproxy-for-mac/refs/heads/main/install)"
```

## 🐧 Quick Install for Linux

Open your Terminal and run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/khmuhtadin/cliproxy-for-mac/refs/heads/main/install-linux)"
```

## 🛠️ Menu Options

When you run the script, you will see an interactive menu:

1.  **Install Homebrew** (macOS Only) / **Install Dependencies** (Linux Only): Required package manager and dependencies.
2.  **Install Git & Go**: Required dependencies.
3.  **Install / Update CLIProxy Core**: Updates the core binary and merges new models into your config.
4.  **FULL INSTALL (Recommended)**: Runs everything in order (1 -> 2 -> 3).

## 📖 How to Use

After installation is complete, **restart your terminal** to load the shortcuts.

### 1. Login to Providers

Run the login script to authenticate with providers (Antigravity, Copilot, Gemini, etc.):

```bash
cp-login
```

*Select your preferred provider from the menu and follow the browser instructions.*

### 2. Start the Proxy

Start the local server. Keep this terminal window open while using Droid/Cursor:

```bash
cp-start
```

### 3. Update Everything

To update the installer script, the core binary, and add new models to your config:

```bash
cp-update
```

### 4. Usage in Droid/Cursor

1.  Open Droid.
2.  Go to Model selection.
3.  You will see new models like **"Claude Opus 4.5 Thinking [Antigravity]"** or **"GPT-5 Mini [Copilot]"**.
4.  Select one and start chatting!

## ⌨️ Shortcuts Reference

* `cp-login` : Open the login menu.
* `cp-start` : Start the proxy server.
* `cp-update`: **(New)** Auto-update the installer and core binary.

## 📂 File Locations

  * **Binary**: `~/bin/cliproxyapi-plus`
  * **Config**: `~/.cli-proxy-api/config.yaml`
  * **Scripts**: `~/.cli-proxy-api/scripts/`
  * **Droid Config**: `~/.factory/config.json`

## Credits

  * Installer script ported and maintained by [khmuhtadin](https://github.com/khmuhtadin).
  * Core application by [router-for-me/CLIProxyAPIPlus](https://github.com/router-for-me/CLIProxyAPIPlus).

-----

*Disclaimer: This project is for educational purposes only. Please ensure you comply with the terms of service of the respective AI providers.*
