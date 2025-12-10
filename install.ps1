<#
.SYNOPSIS
    CLIProxy Ultimate Installer for Windows
.DESCRIPTION
    Sets up CLIProxyAPI-Plus, Droid Config, and Shortcuts on Windows.
    Equivalent to the macOS/Linux 'install' scripts.
#>

param(
    [switch]$Update
)

# --- Configuration & Paths ---
$RepoUrl = "https://github.com/router-for-me/CLIProxyAPIPlus.git"
$BinDir = "$env:USERPROFILE\bin"
$ConfigDir = "$env:USERPROFILE\.cli-proxy-api"
$ScriptsDir = "$ConfigDir\scripts"
$DroidConfigFile = "$env:USERPROFILE\.factory\config.json"
$PowerShellProfile = $PROFILE

# --- Colors ---
function Write-Green { param($Text) Write-Host $Text -ForegroundColor Green }
function Write-Yellow { param($Text) Write-Host $Text -ForegroundColor Yellow }
function Write-Red { param($Text) Write-Host $Text -ForegroundColor Red }
function Write-Cyan { param($Text) Write-Host $Text -ForegroundColor Cyan }

# --- Helper Functions ---

function Check-Dependencies {
    $missing = $false

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Red "[Error] Git not found."
        Write-Host "Please install Git for Windows: https://git-scm.com/download/win"
        $missing = $true
    } else {
        Write-Green "[OK] Git found."
    }

    if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
        Write-Red "[Error] Go not found."
        Write-Host "Please install Go: https://go.dev/dl/"
        $missing = $true
    } else {
        Write-Green "[OK] Go found."
    }

    if ($missing) { exit 1 }
}

function Setup-Shortcuts {
    Write-Yellow "Setting up shortcuts (cp-login, cp-start, cp-update)..."

    # Create the Profile if it doesn't exist
    if (-not (Test-Path $PowerShellProfile)) {
        New-Item -Path $PowerShellProfile -ItemType File -Force | Out-Null
    }

    # Define the block of code to inject
    $shortcutBlock = @"

# --- CLIProxy Shortcuts ---
function cp-start { & "$ScriptsDir\start.ps1" }
function cp-login { & "$ScriptsDir\login.ps1" }
function cp-update {
    Write-Host "Updating CLIProxy..."
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/khmuhtadin/cliproxy-installer/main/install.ps1" -OutFile "$env:TEMP\install.ps1"
    powershell -ExecutionPolicy Bypass -File "$env:TEMP\install.ps1" -Update
}
"@

    # Read current profile
    $currentProfileContent = Get-Content $PowerShellProfile -Raw -ErrorAction SilentlyContinue

    # Remove old CLIProxy shortcuts block if exists
    if ($currentProfileContent -match "(?s)# --- CLIProxy Shortcuts ---.*?(?=\r?\n# ---|$)") {
        Write-Host "Removing old shortcuts..."
        $currentProfileContent = $currentProfileContent -replace "(?s)# --- CLIProxy Shortcuts ---.*?function cp-update \{[^}]+\}", ""
        Set-Content -Path $PowerShellProfile -Value $currentProfileContent.Trim()
    }

    # Add new shortcuts
    if (-not ($currentProfileContent -match "# --- CLIProxy Shortcuts ---")) {
        Add-Content -Path $PowerShellProfile -Value $shortcutBlock
        Write-Green "[OK] Shortcuts added to $PowerShellProfile"
    } else {
        Write-Yellow "[!] Shortcuts already exist. Skipped."
    }
}

function Install-CLIProxy {
    Check-Dependencies

    Write-Yellow ">>> Starting CLIProxy Installation..."

    # Create Dirs
    New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
    New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
    New-Item -ItemType Directory -Force -Path $ScriptsDir | Out-Null

    # Create static directory for dashboard
    $StaticDir = "$ConfigDir\static"
    New-Item -ItemType Directory -Force -Path $StaticDir | Out-Null

    # Install enhanced dashboard
    Write-Host "📊 Installing enhanced dashboard..."
    $DashboardSrc = Join-Path (Split-Path $PSCommandPath) "assets\static\dashboard.html"
    if (Test-Path $DashboardSrc) {
        Copy-Item $DashboardSrc "$StaticDir\dashboard.html" -Force
        Write-Green "[OK] Dashboard installed from local assets"
    } else {
        # Fallback: download from GitHub
        try {
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/khmuhtadin/cliproxy-installer/main/assets/static/dashboard.html" -OutFile "$StaticDir\dashboard.html" -ErrorAction Stop
            Write-Green "[OK] Dashboard downloaded from GitHub"
        } catch {
            Write-Yellow "[!] Could not install dashboard"
        }
    }

    # Install cp-db command (PowerShell function)
    Write-Host "🔮 Installing cp-db shortcut..."
    $CpDbSrc = Join-Path (Split-Path $PSCommandPath) "assets\scripts\cp-db.ps1"
    $CpDbDest = "$ScriptsDir\cp-db.ps1"
    if (Test-Path $CpDbSrc) {
        Copy-Item $CpDbSrc $CpDbDest -Force
        Write-Green "[OK] cp-db installed from local assets"
    } else {
        # Fallback: download from GitHub
        try {
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/khmuhtadin/cliproxy-installer/main/assets/scripts/cp-db.ps1" -OutFile $CpDbDest -ErrorAction Stop
            Write-Green "[OK] cp-db downloaded from GitHub"
        } catch {
            Write-Yellow "[!] Could not install cp-db command"
        }
    }


    # Add Bin to Path if needed (Temporary for this session, User needs to set env var persistently if not set)
    $env:Path += ";$BinDir"

    # Clone & Build
    $TempDir = Join-Path $env:TEMP ("cliproxy_build_" + (Get-Random))
    New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

    Write-Host "Cloning repository..."
    try {
        git clone --depth 1 $RepoUrl $TempDir
        if ($LASTEXITCODE -ne 0) {
            throw "Git clone failed"
        }
    } catch {
        Write-Red "[Error] Failed to clone repository: $_"
        Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
        exit 1
    }

    Write-Host "Building binary..."
    Push-Location $TempDir
    try {
        go build -o cliproxyapi-plus.exe ./cmd/server
        if ($LASTEXITCODE -ne 0) {
            throw "Go build failed"
        }
    } catch {
        Write-Red "[Error] Failed to build binary: $_"
        Pop-Location
        Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
        exit 1
    }

    Move-Item -Force -Path "cliproxyapi-plus.exe" -Destination "$BinDir\cliproxyapi-plus.exe"
    Pop-Location
    Remove-Item -Recurse -Force $TempDir

    Write-Green "[OK] Binary built and installed successfully."

    # Config.yaml
    if (-not (Test-Path "$ConfigDir\config.yaml")) {
        $configContent = @"
port: 8317
auth-dir: "$($ConfigDir -replace '\\', '/')"
api-keys:
  - "sk-dummy"
quota-exceeded:
  switch-project: true
  switch-preview-model: true
"@
        Set-Content -Path "$ConfigDir\config.yaml" -Value $configContent -Encoding UTF8
    }

    # Helper Scripts (PowerShell versions)

    # 1. Start Script
    $startScript = @"
Write-Host "Starting CLIProxy on http://localhost:8317"
& "$BinDir\cliproxyapi-plus.exe" --config "$ConfigDir\config.yaml"
"@
    Set-Content -Path "$ScriptsDir\start.ps1" -Value $startScript

    # 2. Login Script
    $loginScript = @"
`$Binary = "$BinDir\cliproxyapi-plus.exe"
`$Config = "$ConfigDir\config.yaml"
Clear-Host
Write-Host "1. Antigravity (Claude/Gemini)"
Write-Host "2. GitHub Copilot"
Write-Host "3. Gemini CLI"
Write-Host "4. Codex"
Write-Host "5. Claude"
Write-Host "6. Qwen"
Write-Host "7. iFlow"
Write-Host "8. Kiro"
`$choice = Read-Host "Select provider (1-8)"

switch (`$choice) {
    '1' { & `$Binary --config `$Config -antigravity-login }
    '2' { & `$Binary --config `$Config -github-copilot-login }
    '3' { & `$Binary --config `$Config -login }
    '4' { & `$Binary --config `$Config -codex-login }
    '5' { & `$Binary --config `$Config -claude-login }
    '6' { & `$Binary --config `$Config -qwen-login }
    '7' { & `$Binary --config `$Config -iflow-login }
    '8' { & `$Binary --config `$Config -kiro-login }
    Default { Write-Host "Invalid choice" }
}
"@
    Set-Content -Path "$ScriptsDir\login.ps1" -Value $loginScript

    # --- Droid Config Injection (Smart Merge) ---
    Write-Yellow "Checking Droid configuration..."

    # Ensure directory exists
    if (-not (Test-Path (Split-Path $DroidConfigFile))) {
        New-Item -ItemType Directory -Force -Path (Split-Path $DroidConfigFile) | Out-Null
    }

    # Define New Models
    $NewModels = @(
        @{ model_display_name = "GPT-OSS 120B Medium [Antigravity]"; model = "gpt-oss-120b-medium"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "GPT-OSS 120B Large [Antigravity]"; model = "gpt-oss-120b-large"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Claude Opus 4.5 Thinking [Antigravity]"; model = "gemini-claude-opus-4-5-thinking"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Claude Sonnet 4.5 Thinking [Antigravity]"; model = "gemini-claude-sonnet-4-5-thinking"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Claude Sonnet 4.5 [Antigravity]"; model = "gemini-claude-sonnet-4-5"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Gemini 3 Pro [Antigravity]"; model = "gemini-3-pro-preview"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Claude Opus 4.5 [Copilot]"; model = "claude-opus-4.5"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "GPT-5 Mini [Copilot]"; model = "gpt-5-mini"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "GPT-5.1 Codex Max [Codex]"; model = "gpt-5.1-codex-max"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Gemini 3 Ultra [Antigravity]"; model = "gemini-3-ultra-preview"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Llama 4 405B [Meta]"; model = "llama-4-405b-instruct"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Nano Banana [Local]"; model = "nano-banana-v1"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Gemini 2.5 Pro [Gemini]"; model = "gemini-2.5-pro"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Qwen3 Coder Plus [Qwen]"; model = "qwen3-coder-plus"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "GLM 4.6 [iFlow]"; model = "glm-4.6"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Claude Opus 4.5 [Kiro]"; model = "kiro-claude-opus-4.5"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Claude Sonnet 4.5 [Kiro]"; model = "kiro-claude-sonnet-4.5"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Claude Sonnet 4 [Kiro]"; model = "kiro-claude-sonnet-4"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Claude Haiku 4.5 [Kiro]"; model = "kiro-claude-haiku-4.5"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" }
    )

    if (Test-Path $DroidConfigFile) {
        Write-Host "Existing config found. Merging models..."
        try {
            $jsonContent = Get-Content $DroidConfigFile -Raw | ConvertFrom-Json

            # Ensure custom_models array exists
            if (-not $jsonContent.PSObject.Properties['custom_models']) {
                $jsonContent | Add-Member -MemberType NoteProperty -Name "custom_models" -Value @()
            }

            # Create a hashset of existing model IDs for fast lookup
            $existingIDs = @{}
            foreach ($m in $jsonContent.custom_models) {
                $existingIDs[$m.model] = $true
            }

            $addedCount = 0
            foreach ($newModel in $NewModels) {
                if (-not $existingIDs.ContainsKey($newModel.model)) {
                    $jsonContent.custom_models += $newModel
                    $addedCount++
                }
            }

            if ($addedCount -gt 0) {
                $jsonContent | ConvertTo-Json -Depth 10 | Set-Content $DroidConfigFile -Encoding UTF8
                Write-Green "Merged $addedCount new models."
            } else {
                Write-Host "All models already exist."
            }

        } catch {
            Write-Red "Error parsing existing JSON. Backing up and overwriting..."
            Copy-Item $DroidConfigFile "$DroidConfigFile.bak"
            @{ custom_models = $NewModels } | ConvertTo-Json -Depth 10 | Set-Content $DroidConfigFile -Encoding UTF8
        }
    } else {
        Write-Green "Creating new config.json..."
        @{ custom_models = $NewModels } | ConvertTo-Json -Depth 10 | Set-Content $DroidConfigFile -Encoding UTF8
    }

    Setup-Shortcuts

    Write-Green "========================================"
    Write-Green "  INSTALLATION SUCCESS!"
    Write-Green "========================================"
    Write-Host "Please restart your PowerShell terminal to use shortcuts:"
    Write-Cyan "  1. Login:  cp-login"
    Write-Cyan "  2. Start:  cp-start"
    Write-Cyan "  3. Update: cp-update"
}

# --- Execution Flow ---

if ($Update) {
    Install-CLIProxy
    exit
}

Clear-Host
Write-Cyan "========================================"
Write-Cyan "   CLIProxy Windows Installer Manager"
Write-Cyan "========================================"
Write-Host ""
Write-Host "1. Install / Update CLIProxy Core"
Write-Host "2. Exit"
Write-Host ""
$menuChoice = Read-Host "Please select your choice (1-2)"

switch ($menuChoice) {
    '1' { Install-CLIProxy }
    '2' { exit }
    Default { Write-Red "Invalid choice." }
}
