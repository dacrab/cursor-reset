#!/bin/bash

# Define the path to the storage.json file
STORAGE_PATH="$HOME/.config/Cursor/User/globalStorage/storage.json"

# Logo
LOGO="
   ██████╗██╗   ██╗██████╗ ███████╗ ██████╗ ██████╗ 
  ██╔════╝██║   ██║██╔══██╗██╔════╝██╔═══██╗██╔══██╗
  ██║     ██║   ██║██████╔╝███████╗██║   ██║██████╔╝
  ██║     ██║   ██║██╔══██╗╚════██║██║   ██║██╔══██╗
  ╚██████╗╚██████╔╝██║  ██║███████║╚██████╔╝██║  ██║
   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
"

# Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

# Print the logo
echo -e "${BLUE}$LOGO${RESET}"
echo -e "${YELLOW}=== Cursor Telemetry ID Updater ===${RESET}"
echo ""

# Check if the file exists
if [[ ! -f "$STORAGE_PATH" ]]; then
  echo -e "${RED}Error: Cursor's storage.json file not found at $STORAGE_PATH!${RESET}"
  exit 1
fi

# Load the JSON file
data=$(cat "$STORAGE_PATH")

# Extract current values
machineId=$(echo "$data" | jq -r '.["telemetry.machineId"]')
macMachineId=$(echo "$data" | jq -r '.["telemetry.macMachineId"]')
devDeviceId=$(echo "$data" | jq -r '.["telemetry.devDeviceId"]')

# Display current values
echo -e "${YELLOW}Current Values:${RESET}"
echo -e "${BLUE}telemetry.machineId: ${GREEN}$machineId${RESET}"
echo -e "${BLUE}telemetry.macMachineId: ${GREEN}$macMachineId${RESET}"
echo -e "${BLUE}telemetry.devDeviceId: ${GREEN}$devDeviceId${RESET}"
echo ""

# Add a delay for better UX
sleep 1

# Generate new UUIDs
new_machineId=$(uuidgen)
new_macMachineId=$(uuidgen)
new_devDeviceId=$(uuidgen)

# Display new values
echo -e "${YELLOW}New Values:${RESET}"
echo -e "${BLUE}telemetry.machineId: ${GREEN}$new_machineId${RESET}"
echo -e "${BLUE}telemetry.macMachineId: ${GREEN}$new_macMachineId${RESET}"
echo -e "${BLUE}telemetry.devDeviceId: ${GREEN}$new_devDeviceId${RESET}"
echo ""

# Add a delay for better UX
sleep 1

# Update the JSON file
updated_data=$(echo "$data" | jq \
  --arg new_machineId "$new_machineId" \
  --arg new_macMachineId "$new_macMachineId" \
  --arg new_devDeviceId "$new_devDeviceId" \
  '.["telemetry.machineId"] = $new_machineId |
   .["telemetry.macMachineId"] = $new_macMachineId |
   .["telemetry.devDeviceId"] = $new_devDeviceId')

# Save the updated JSON back to the file
echo "$updated_data" | jq . > "$STORAGE_PATH"

echo -e "${GREEN}✅ storage.json updated successfully!${RESET}"
echo ""

# Prompt the user to restart Cursor
echo -e "${YELLOW}Please restart Cursor for the changes to take effect.${RESET}"