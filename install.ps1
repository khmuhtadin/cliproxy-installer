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
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/khmuhtadin/cliproxy-for-mac/main/install.ps1" -OutFile "$env:TEMP\install.ps1"
    powershell -ExecutionPolicy Bypass -File "$env:TEMP\install.ps1" -Update
}
"@

    # Read current profile
    $currentProfileContent = Get-Content $PowerShellProfile -Raw -ErrorAction SilentlyContinue
    
    # Remove old blocks if they exist to prevent duplicates (Simple check)
    if ($currentProfileContent -match "# --- CLIProxy Shortcuts ---") {
        Write-Host "Shortcuts already exist in profile. Updating..."
        # In a real scenario, robust regex replacement is better, but appending works if we assume user manages their profile.
        # For safety, we will just notify.
    } else {
        Add-Content -Path $PowerShellProfile -Value $shortcutBlock
        Write-Green "[OK] Shortcuts added to $PowerShellProfile"
    }
}

function Install-CLIProxy {
    Check-Dependencies

    Write-Yellow ">>> Starting CLIProxy Installation..."

    # Create Dirs
    New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
    New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
    New-Item -ItemType Directory -Force -Path $ScriptsDir | Out-Null

    # Add Bin to Path if needed (Temporary for this session, User needs to set env var persistently if not set)
    $env:Path += ";$BinDir"
    
    # Clone & Build
    $TempDir = Join-Path $env:TEMP ("cliproxy_build_" + (Get-Random))
    New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
    
    Write-Host "Cloning repository..."
    git clone --depth 1 $RepoUrl $TempDir
    
    Write-Host "Building binary..."
    Push-Location $TempDir
    go build -o cliproxyapi-plus.exe ./cmd/server
    
    Move-Item -Force -Path "cliproxyapi-plus.exe" -Destination "$BinDir\cliproxyapi-plus.exe"
    Pop-Location
    Remove-Item -Recurse -Force $TempDir

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
`$choice = Read-Host "Select provider (1-7)"

switch (`$choice) {
    '1' { & `$Binary --config `$Config -antigravity-login }
    '2' { & `$Binary --config `$Config -github-copilot-login }
    '3' { & `$Binary --config `$Config -login }
    '4' { & `$Binary --config `$Config -codex-login }
    '5' { & `$Binary --config `$Config -claude-login }
    '6' { & `$Binary --config `$Config -qwen-login }
    '7' { & `$Binary --config `$Config -iflow-login }
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
        @{ model_display_name = "DeepSeek V3.2 [Antigravity]"; model = "deepseek-v3.2-chat"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Nano Banana [Local]"; model = "nano-banana-v1"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Gemini 2.5 Pro [Gemini]"; model = "gemini-2.5-pro"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Qwen3 Coder Plus [Qwen]"; model = "qwen3-coder-plus"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "GLM 4.6 [iFlow]"; model = "glm-4.6"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Claude Opus 4.5 [Kiro]"; model = "kiro-claude-opus-4.5"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Claude Sonnet 4.5 [Kiro]"; model = "kiro-claude-sonnet-4.5"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy"; provider = "openai" },
        @{ model_display_name = "Claude Sonnet 4 [Kiro]"; model = "kiro-claude-sonnet-4"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy", "provider": "openai" },
        @{ model_display_name = "Claude Haiku 4.5 [Kiro]"; model = "kiro-claude-haiku-4.5"; base_url = "http://localhost:8317/v1"; api_key = "sk-dummy", "provider": "openai" }
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
