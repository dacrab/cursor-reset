# Define paths
$storagePath = "$env:APPDATA\Cursor\User\globalStorage\storage.json"
$mainJsPath = "${env:LOCALAPPDATA}\Programs\Cursor\resources\app\out\main.js"
$backupDir = Join-Path $HOME "CursorID_Backups"
$registryPath = "HKLM:\SOFTWARE\Microsoft\Cryptography"

# Logo display
$LOGO = @"
   ██████╗██╗   ██╗██████╗ ███████╗ ██████╗ ██████╗ 
  ██╔════╝██║   ██║██╔══██╗██╔════╝██╔═══██╗██╔══██╗
  ██║     ██║   ██║██████╔╝███████╗██║   ██║██████╔╝
  ██║     ██║   ██║██╔══██╗╚════██║██║   ██║██╔══██╗
  ╚██████╗╚██████╔╝██║  ██║███████║╚██████╔╝██║  ██║
   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
"@

Write-Host $LOGO -ForegroundColor Cyan
Write-Host "=== Cursor Identity Reset Tool ===" -ForegroundColor Yellow
Write-Host ""

# Check admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Error: This script requires administrator privileges!" -ForegroundColor Red
    exit
}

# Check if Cursor is running
$cursorProcesses = Get-Process "cursor" -ErrorAction SilentlyContinue
if ($cursorProcesses) {
    Write-Host "Cursor is running. Please close Cursor to continue..." -ForegroundColor Yellow
    Write-Host "Waiting for Cursor to exit..."
    
    while ($true) {
        $cursorProcesses = Get-Process "cursor" -ErrorAction SilentlyContinue
        if (-not $cursorProcesses) {
            Write-Host "Cursor closed. Continuing..." -ForegroundColor Green
            break
        }
        Start-Sleep -Seconds 1
    }
}

# Backup system identifiers
function Backup-SystemIds {
    param(
        [string]$backupDir
    )
    
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir | Out-Null
    }

    # Backup MachineGuid
    try {
        $machineGuid = (Get-ItemProperty -Path $registryPath).MachineGuid
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = Join-Path $backupDir "MachineGuid_$timestamp.txt"
        $machineGuid | Out-File $backupFile
        Write-Host "Backup created: $backupFile" -ForegroundColor Blue
    }
    catch {
        Write-Host "Error backing up MachineGuid: $_" -ForegroundColor Red
    }
}

# ID Generation Functions
function New-MacMachineId {
    $template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    $result = ""
    $random = [Random]::new()
    
    foreach ($char in $template.ToCharArray()) {
        switch ($char) {
            'x' { $result += [Convert]::ToString($random.Next(16), 16) }
            'y' { $result += [Convert]::ToString(($random.Next(4) + 8), 16) }
            default { $result += $char }
        }
    }
    return $result
}

function New-RandomId {
    $uuid1 = [guid]::NewGuid().ToString("N")
    $uuid2 = [guid]::NewGuid().ToString("N")
    return $uuid1 + $uuid2
}

# Main execution
try {
    # Create backups
    Backup-SystemIds -backupDir $backupDir

    # Generate new IDs
    $newMachineId = New-RandomId
    $newMacMachineId = New-MacMachineId
    $newDevDeviceId = [guid]::NewGuid().ToString()
    $newSqmId = "{$([guid]::NewGuid().ToString().ToUpper())}"
    $newMainMachineId = [guid]::NewGuid().ToString("N").Substring(0,32)

    # Update storage.json
    if (Test-Path $storagePath) {
        $originalAttributes = (Get-Item $storagePath).Attributes
        Set-ItemProperty $storagePath -Name Attributes -Value Normal

        $jsonContent = Get-Content $storagePath -Raw | ConvertFrom-Json
        
        # Update telemetry properties
        $properties = @{
            "telemetry.machineId" = $newMachineId
            "telemetry.macMachineId" = $newMacMachineId
            "telemetry.devDeviceId" = $newDevDeviceId
            "telemetry.sqmId" = $newSqmId
        }

        foreach ($prop in $properties.Keys) {
            if ($jsonContent.PSObject.Properties.Name -contains $prop) {
                $jsonContent.$prop = $properties[$prop]
            }
            else {
                $jsonContent | Add-Member -NotePropertyName $prop -NotePropertyValue $properties[$prop]
            }
        }

        # Save with proper encoding
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText(
            $storagePath,
            ($jsonContent | ConvertTo-Json -Depth 10),
            $utf8NoBom
        )
        Set-ItemProperty $storagePath -Name Attributes -Value $originalAttributes
    }

    # Update main.js
    if (Test-Path $mainJsPath) {
        Copy-Item $mainJsPath "$mainJsPath.backup" -Force
        $jsContent = Get-Content $mainJsPath -Raw
        $jsContent = $jsContent -replace '(?<=getMachineId\(\)\s*{\s*return\s*[''"])([^''"]+)(?=[''"])', $newMainMachineId
        $jsContent | Set-Content $mainJsPath -Force
    }

    # Update registry
    Set-ItemProperty -Path $registryPath -Name "MachineGuid" -Value ([guid]::NewGuid().ToString()) -Force

    # Display results
    Write-Host "`nSuccessfully updated identifiers:" -ForegroundColor Green
    Write-Host "• MachineGuid (Registry): " -NoNewline -ForegroundColor Cyan
    Write-Host (Get-ItemProperty $registryPath).MachineGuid
    
    Write-Host "• telemetry.machineId: " -NoNewline -ForegroundColor Cyan
    Write-Host $newMachineId
    
    Write-Host "• telemetry.macMachineId: " -NoNewline -ForegroundColor Cyan
    Write-Host $newMacMachineId
    
    Write-Host "• main.js machineId: " -NoNewline -ForegroundColor Cyan
    Write-Host $newMainMachineId
    
    Write-Host "`nBackups stored in: $backupDir" -ForegroundColor Blue
    Write-Host "Please restart Cursor to apply changes" -ForegroundColor Yellow
}
catch {
    Write-Host "`nError occurred: $_" -ForegroundColor Red
    exit 1
}