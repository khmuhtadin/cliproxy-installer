# Changelog - Code Quality & Platform Fixes

## Overview
Fixed code quality issues, platform-specific bugs, and improved the update mechanism across all installer scripts.

## Changes Made

### 1. **Created Shared Config Merge Utility** ✅
- **File**: `merge-config.go`
- **Purpose**: Eliminated 160+ lines of duplicated code between macOS and Linux installers
- **Benefits**: 
  - Single source of truth for config merging logic
  - Better error messages
  - Easier to maintain and update
  - Downloaded on-demand during installation

### 2. **Fixed Windows PowerShell Script** ✅
- **Fixed JSON syntax errors**: Lines 160-161 had incorrect syntax (`,` instead of `:`)
- **Improved shortcut management**: Now properly removes old shortcuts before adding new ones
- **Added error handling**: Git clone and Go build failures now properly exit with error messages
- **Better user feedback**: Added success messages for each step

### 3. **Enhanced macOS Installer** ✅
- **Error handling**: Added proper error checks for:
  - Git clone failures
  - Go build failures
  - Config merge failures
- **Config preservation**: Now preserves existing `config.yaml` during updates
- **Improved sed safety**: Added error suppression for cleaner output
- **Better update flow**: Update mode (`-update`) now shows clear progress messages

### 4. **Enhanced Linux Installer** ✅
- **Fish shell support**: Full support for Fish shell (previously only warned users)
  - Detects Fish shell
  - Creates Fish-compatible aliases
  - Adds `$HOME/bin` to Fish PATH
- **Error handling**: Same improvements as macOS installer
- **Config preservation**: Preserves user settings during updates
- **Cross-distribution compatibility**: Improved PATH setup for various distros

### 5. **Improved Update Mechanism** ✅
All three installers now:
- Preserve user's `config.yaml` customizations
- Only merge new models without overwriting existing config
- Show clear progress during updates
- Use shared merge utility for consistency
- Handle errors gracefully with fallback behavior

## Code Quality Improvements

### Before
- **193 lines of duplicated code** between installers
- No error handling for critical operations
- Incomplete Fish shell support
- Windows JSON syntax errors
- Overwrote user configs on update

### After
- **Shared merge utility** eliminates duplication
- **Comprehensive error handling** with exit codes
- **Full Fish shell support** in Linux installer
- **Fixed all syntax errors**
- **Preserves user customizations** during updates

## Testing Recommendations

1. **macOS**: Test on both zsh and bash
2. **Linux**: Test on Ubuntu/Debian, Fedora, Arch, and with Fish shell
3. **Windows**: Test PowerShell profile update mechanism
4. **Update flow**: Run `cp-update` on existing installations to verify config preservation

## Migration Notes

- Existing installations will automatically benefit from these fixes on next update
- The new `merge-config.go` utility is fetched on-demand (not included in old installs)
- No manual intervention required for users

## Files Changed

1. `install` (macOS) - 127 lines changed
2. `install-linux` - 142 lines changed  
3. `install.ps1` (Windows) - 46 lines changed
4. `merge-config.go` (NEW) - Shared utility

**Total**: 193 lines removed (duplicates), 122 lines improved

## [Unreleased] - 2025-12-10

### Added
- **Enhanced Dashboard**: Modern, premium dashboard with glassmorphism design
  - Real-time server monitoring
  - Provider and model management UI
  - Activity logging with color-coded events
  - Smart server control buttons with fallback instructions
  - Auto-refresh every 10 seconds
  - Modern typography with Google Fonts (Inter)
  - Animated backgrounds and hover effects
  - Responsive layout for mobile and desktop

- **cp-db Command**: Smart dashboard launcher
  - Auto-checks if server is running
  - Auto-starts server if needed
  - Opens dashboard in default browser
  - Cross-platform support (macOS/Linux)
  
### Changed
- Installer now includes assets directory for bundled files
- Dashboard installation integrated into main install script
- Success message updated to show cp-db command

### Technical Details
- Dashboard uses modern CSS with glassmorphism effects
- JavaScript handles real-time data fetching from management API
- Fallback strategies for PID display
- Smart error handling with helpful user instructions

