# Define the path to the storage.json file
$storagePath = "$env:APPDATA\Cursor\User\globalStorage\storage.json"

# Logo
$LOGO = @"
   ██████╗██╗   ██╗██████╗ ███████╗ ██████╗ ██████╗ 
  ██╔════╝██║   ██║██╔══██╗██╔════╝██╔═══██╗██╔══██╗
  ██║     ██║   ██║██████╔╝███████╗██║   ██║██████╔╝
  ██║     ██║   ██║██╔══██╗╚════██║██║   ██║██╔══██╗
  ╚██████╗╚██████╔╝██║  ██║███████║╚██████╔╝██║  ██║
   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
"@

# Print the logo
Write-Host $LOGO -ForegroundColor Blue
Write-Host "=== Cursor Telemetry ID Updater ===" -ForegroundColor Yellow
Write-Host ""

# Check if the file exists
if (-Not (Test-Path $storagePath)) {
  Write-Host "Error: Cursor's storage.json file not found at $storagePath!" -ForegroundColor Red
  exit
}

# Load the JSON file
$data = Get-Content -Path $storagePath | ConvertFrom-Json

# Extract current values
$machineId = $data.telemetry.machineId
$macMachineId = $data.telemetry.macMachineId
$devDeviceId = $data.telemetry.devDeviceId

# Display current values
Write-Host "Current Values:" -ForegroundColor Yellow
Write-Host "telemetry.machineId: $machineId" -ForegroundColor Green
Write-Host "telemetry.macMachineId: $macMachineId" -ForegroundColor Green
Write-Host "telemetry.devDeviceId: $devDeviceId" -ForegroundColor Green
Write-Host ""

# Add a delay for better UX
Start-Sleep -Seconds 1

# Generate new GUIDs (UUIDs)
$new_machineId = [guid]::NewGuid().ToString()
$new_macMachineId = [guid]::NewGuid().ToString()
$new_devDeviceId = [guid]::NewGuid().ToString()

# Display new values
Write-Host "New Values:" -ForegroundColor Yellow
Write-Host "telemetry.machineId: $new_machineId" -ForegroundColor Green
Write-Host "telemetry.macMachineId: $new_macMachineId" -ForegroundColor Green
Write-Host "telemetry.devDeviceId: $new_devDeviceId" -ForegroundColor Green
Write-Host ""

# Add a delay for better UX
Start-Sleep -Seconds 1

# Update the JSON data
$data.telemetry.machineId = $new_machineId
$data.telemetry.macMachineId = $new_macMachineId
$data.telemetry.devDeviceId = $new_devDeviceId

# Save the updated JSON back to the file
$data | ConvertTo-Json -Depth 10 | Set-Content -Path $storagePath

Write-Host "✅ storage.json updated successfully!" -ForegroundColor Green
Write-Host ""

# Prompt the user to restart Cursor
Write-Host "Please restart Cursor for the changes to take effect." -ForegroundColor Yellow