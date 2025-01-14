# Cursor Reset Tool 🔄

<div align="center">

<img src="https://ai-cursor.com/wp-content/uploads/2024/09/logo-cursor-ai-png.webp" alt="Cursor Logo" width="120"/>

```
Too many free trial accounts used on this machine.
Please upgrade to pro. We have this limit in place
to prevent abuse. Please let us know if you believe
this is a mistake.
```

A simple tool to reset Cursor Editor's device identifiers.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

## 🚀 Quick Start

### Linux/macOS
```bash
curl -s https://raw.githubusercontent.com/dacrab/cursor-reset/main/cursor_reset.sh | bash
```

### Windows
```powershell
iwr -useb https://raw.githubusercontent.com/dacrab/cursor-reset/main/cursor_reset.ps1 | iex
```

## 📝 What These Scripts Do

The scripts modify Cursor Editor's configuration file to reset device identifiers. Here's the detailed breakdown:

### Configuration File Location
- **Windows**: `%APPDATA%\Cursor\User\globalStorage\storage.json`
- **Linux/macOS**: `~/.config/Cursor/User/globalStorage/storage.json`

### Modified Values
The scripts update three specific identifiers in the configuration file:
```json
{
  "telemetry": {
    "machineId": "<new-random-uuid>",
    "macMachineId": "<new-random-uuid>",
    "devDeviceId": "<new-random-uuid>"
  }
}
```
Each UUID is randomly generated during script execution to ensure uniqueness.

### Process
1. Locates the configuration file based on your operating system
2. Creates backup of existing configuration (in memory)
3. Generates new random UUIDs/GUIDs
4. Safely updates the configuration file
5. Preserves all other settings and preferences

## ✨ Features

- Beautiful cyberpunk-style ASCII art
- Automatic UUID/GUID generation
- Progress spinner animation
- Color-coded output messages
- Cross-platform support (Windows, Linux, macOS)
- Safe file handling with error checking
- No external dependencies required

## ⚠️ Important Notes

- Please restart Cursor Editor after running the script for changes to take effect
- The script automatically backs up the configuration in memory
- All other settings and preferences remain unchanged
- The script requires appropriate file permissions to modify the configuration file

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/dacrab/cursor-reset/issues).
