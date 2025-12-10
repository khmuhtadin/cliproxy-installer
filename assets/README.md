# CLIProxy Installer Assets

This directory contains additional assets that will be installed during the CLIProxy installation process.

## Directory Structure

```
assets/
├── static/
│   └── dashboard.html      # Enhanced dashboard with modern UI
└── scripts/
    └── cp-db.sh             # Dashboard launcher shortcut
```

## Files

### static/dashboard.html
Modern, premium dashboard for CLIProxy with features:
- Glassmorphism design with animated backgrounds
- Real-time server status monitoring
- Provider and model management
- Activity logging
- Smart server controls
- Auto-refresh capabilities

### scripts/cp-db.sh
Smart dashboard launcher that:
- Checks if CLIProxy server is running
- Auto-starts server if needed
- Opens dashboard in default browser
- Works on macOS and Linux

## Installation

These assets are automatically installed when you run the main installer.

The installer will:
1. Copy `dashboard.html` to `~/.cli-proxy-api/static/dashboard.html`
2. Install `cp-db.sh` to `/usr/local/bin/cp-db` (requires sudo)

## Usage

After installation:

```bash
# Open dashboard (auto-starts server if needed)
cp-db

# Or access directly
open http://localhost:8317/dashboard.html
```

## Updates

To update these assets to the latest version:
```bash
cp-update
```
