# Define the paths
$storagePath = "$env:APPDATA\Cursor\User\globalStorage\storage.json"
$mainJsPath = "${env:LOCALAPPDATA}\Programs\Cursor\resources\app\out\main.js"

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

# Function to generate UUID v4
function New-UUIDv4 {
    $uuid = [guid]::NewGuid().ToString()
    # Ensure version is 4
    $uuid = $uuid.Substring(0,14) + "4" + $uuid.Substring(15)
    # Ensure variant is correct (8, 9, a, or b)
    $variants = @("8","9","a","b")
    $randomVariant = $variants | Get-Random
    $uuid = $uuid.Substring(0,19) + $randomVariant + $uuid.Substring(20)
    return $uuid
}

# Check if the files exist
if (-Not (Test-Path $storagePath)) {
    Write-Host "Error: Cursor's storage.json file not found at $storagePath!" -ForegroundColor Red
    exit
}

if (-Not (Test-Path $mainJsPath)) {
    Write-Host "Error: Cursor's main.js file not found at $mainJsPath!" -ForegroundColor Red
    exit
}

# Load the JSON file
$data = Get-Content -Path $storagePath | ConvertFrom-Json

# Extract current values
$machineId = $data.'telemetry.machineId'
$macMachineId = $data.'telemetry.macMachineId'
$devDeviceId = $data.'telemetry.devDeviceId'
$sqmId = $data.'telemetry.sqmId'

# Display current values
Write-Host "Current Values:" -ForegroundColor Yellow
Write-Host "telemetry.machineId: $machineId" -ForegroundColor Green
Write-Host "telemetry.macMachineId: $macMachineId" -ForegroundColor Green
Write-Host "telemetry.devDeviceId: $devDeviceId" -ForegroundColor Green
Write-Host "telemetry.sqmId: $sqmId" -ForegroundColor Green
Write-Host ""

# Add a delay for better UX
Start-Sleep -Seconds 1

# Generate new UUIDs
$new_machineId = New-UUIDv4
$new_macMachineId = New-UUIDv4
$new_devDeviceId = New-UUIDv4
$new_sqmId = New-UUIDv4
$new_main_machine_id = New-UUIDv4

# Display new values
Write-Host "New Values:" -ForegroundColor Yellow
Write-Host "telemetry.machineId: $new_machineId" -ForegroundColor Green
Write-Host "telemetry.macMachineId: $new_macMachineId" -ForegroundColor Green
Write-Host "telemetry.devDeviceId: $new_devDeviceId" -ForegroundColor Green
Write-Host "telemetry.sqmId: $new_sqmId" -ForegroundColor Green
Write-Host "main.js machineId: $new_main_machine_id" -ForegroundColor Green
Write-Host ""

# Add a delay for better UX
Start-Sleep -Seconds 1

# Update the JSON data
$data.'telemetry.machineId' = $new_machineId
$data.'telemetry.macMachineId' = $new_macMachineId
$data.'telemetry.devDeviceId' = $new_devDeviceId
$data.'telemetry.sqmId' = $new_sqmId

# Save the updated JSON back to the file
$data | ConvertTo-Json -Depth 10 | Set-Content -Path $storagePath

# Update main.js
$mainJsContent = Get-Content -Path $mainJsPath -Raw
$mainJsContent = $mainJsContent -replace '(?<=getMachineId\(\)\s*{\s*return\s*[''"])([^''"]+)(?=[''"])', $new_main_machine_id

# Create a backup of main.js
Copy-Item -Path $mainJsPath -Destination "${mainJsPath}.backup" -Force

# Save the modified main.js
$mainJsContent | Set-Content -Path $mainJsPath -Force

Write-Host "✅ Files updated successfully!" -ForegroundColor Green
Write-Host "📝 Backup of main.js created at ${mainJsPath}.backup" -ForegroundColor Blue
Write-Host ""

# Prompt the user to restart Cursor
Write-Host "Please restart Cursor for the changes to take effect." -ForegroundColor Yellow