# Cyberpunk ASCII Logo with "CURSOR"
Write-Host -ForegroundColor Magenta @"
   ██████╗██╗   ██╗██████╗ ███████╗ ██████╗ ██████╗ 
  ██╔════╝██║   ██║██╔══██╗██╔════╝██╔═══██╗██╔══██╗
  ██║     ██║   ██║██████╔╝███████╗██║   ██║██████╔╝
  ██║     ██║   ██║██╔══██╗╚════██║██║   ██║██╔══██╗
  ╚██████╗╚██████╔╝██║  ██║███████║╚██████╔╝██║  ██║
   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
"@

# Define the path to the storage.json file
$configPath = "$env:APPDATA\Cursor\User\globalStorage\storage.json"

# Function to generate a random GUID
function Generate-Guid {
    return [guid]::NewGuid().ToString().ToLower()
}

# Function to display a spinner
function Show-Spinner {
    $spinner = @('|', '/', '-', '\')
    $i = 0
    while ($true) {
        Write-Host -NoNewline "`r$($spinner[$i % 4])"
        Start-Sleep -Milliseconds 100
        $i++
    }
}

# Modify the storage.json file
Write-Host -ForegroundColor Cyan "Modifying configuration file..."
$spinnerJob = Start-Job -ScriptBlock { Show-Spinner }
Start-Sleep -Seconds 1

$json = Get-Content -Path $configPath | ConvertFrom-Json
$json.telemetry.machineId = Generate-Guid
$json.telemetry.macMachineId = Generate-Guid
$json.telemetry.devDeviceId = Generate-Guid
$json | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath

Stop-Job -Job $spinnerJob
Remove-Job -Job $spinnerJob

Write-Host -ForegroundColor Green "Configuration file updated successfully!"
Write-Host -ForegroundColor Yellow "Please restart Cursor for changes to take effect."
Write-Host "`nPress Enter to exit..." -NoNewline
Read-Host