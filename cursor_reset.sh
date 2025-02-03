#!/bin/bash

# Define the paths
STORAGE_PATH="$HOME/'/Users/root/Library/Application Support/Cursor/User/globalStorage/storage.json'"
MACHINE_ID_PATH="$HOME/.config/Cursor/machineid"

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

# Function to generate UUID v4
generate_uuid_v4() {
    # Generate UUID and ensure it follows v4 format (xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx)
    # where y is 8,9,a,b
    uuid=$(uuidgen)
    # Ensure the version nibble (13th character) is 4
    uuid=${uuid:0:14}4${uuid:15}
    # Ensure the variant nibble (17th character) is 8,9,a, or b
    variant=(8 9 a b)
    random_variant=${variant[$RANDOM % 4]}
    uuid=${uuid:0:19}$random_variant${uuid:20}
    echo "$uuid"
}

# Check if the storage.json file exists
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
sqmId=$(echo "$data" | jq -r '.["telemetry.sqmId"]')

# Display current values
echo -e "${YELLOW}Current Values:${RESET}"
echo -e "${BLUE}telemetry.machineId: ${GREEN}$machineId${RESET}"
echo -e "${BLUE}telemetry.macMachineId: ${GREEN}$macMachineId${RESET}"
echo -e "${BLUE}telemetry.devDeviceId: ${GREEN}$devDeviceId${RESET}"
echo -e "${BLUE}telemetry.sqmId: ${GREEN}$sqmId${RESET}"

# Display current machineid file content if it exists
if [[ -f "$MACHINE_ID_PATH" ]]; then
    current_machine_id=$(cat "$MACHINE_ID_PATH")
    echo -e "${BLUE}machineid file: ${GREEN}$current_machine_id${RESET}"
fi
echo ""

# Add a delay for better UX
sleep 1

# Generate new UUIDs using the v4 format
new_machineId=$(generate_uuid_v4)
new_macMachineId=$(generate_uuid_v4)
new_devDeviceId=$(generate_uuid_v4)
new_sqmId=$(generate_uuid_v4)
new_machine_id=$(generate_uuid_v4)

# Display new values
echo -e "${YELLOW}New Values:${RESET}"
echo -e "${BLUE}telemetry.machineId: ${GREEN}$new_machineId${RESET}"
echo -e "${BLUE}telemetry.macMachineId: ${GREEN}$new_macMachineId${RESET}"
echo -e "${BLUE}telemetry.devDeviceId: ${GREEN}$new_devDeviceId${RESET}"
echo -e "${BLUE}telemetry.sqmId: ${GREEN}$new_sqmId${RESET}"
echo -e "${BLUE}machineid file: ${GREEN}$new_machine_id${RESET}"
echo ""

# Add a delay for better UX
sleep 1

# Update the JSON file
updated_data=$(echo "$data" | jq \
    --arg new_machineId "$new_machineId" \
    --arg new_macMachineId "$new_macMachineId" \
    --arg new_devDeviceId "$new_devDeviceId" \
    --arg new_sqmId "$new_sqmId" \
    '.["telemetry.machineId"] = $new_machineId |
     .["telemetry.macMachineId"] = $new_macMachineId |
     .["telemetry.devDeviceId"] = $new_devDeviceId |
     .["telemetry.sqmId"] = $new_sqmId')

# Save the updated JSON back to the file
echo "$updated_data" | jq . > "$STORAGE_PATH"

# Update the machineid file
echo "$new_machine_id" > "$MACHINE_ID_PATH"

echo -e "${GREEN}✅ storage.json and machineid files updated successfully!${RESET}"
echo ""

# Prompt the user to restart Cursor
echo -e "${YELLOW}Please restart Cursor for the changes to take effect.${RESET}"
