#!/bin/bash

# Cyberpunk ASCII Logo with "CURSOR"
echo -e "\e[35m"
cat << "EOF"
   ██████╗██╗   ██╗██████╗ ███████╗ ██████╗ ██████╗ 
  ██╔════╝██║   ██║██╔══██╗██╔════╝██╔═══██╗██╔══██╗
  ██║     ██║   ██║██████╔╝███████╗██║   ██║██████╔╝
  ██║     ██║   ██║██╔══██╗╚════██║██║   ██║██╔══██╗
  ╚██████╗╚██████╔╝██║  ██║███████║╚██████╔╝██║  ██║
   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
EOF
echo -e "\e[0m"

# Define the path to the storage.json file
CONFIG_PATH="$HOME/.config/Cursor/User/globalStorage/storage.json"

# Function to generate a random UUID
generate_uuid() {
    uuidgen | tr '[:upper:]' '[:lower:]'
}

# Function to display a spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Modify the storage.json file
echo -e "\e[36mModifying configuration file...\e[0m"
{
    sleep 1 &
    spinner $!
    jq --arg machineId "$(generate_uuid)" --arg macMachineId "$(generate_uuid)" --arg devDeviceId "$(generate_uuid)" \
    '.telemetry.machineId = $machineId | .telemetry.macMachineId = $macMachineId | .telemetry.devDeviceId = $devDeviceId' \
    "$CONFIG_PATH" > temp.json && mv temp.json "$CONFIG_PATH"
} &> /dev/null

echo -e "\e[32mConfiguration file updated successfully!\e[0m"
echo -e "\e[33mPlease restart Cursor for changes to take effect.\e[0m"
echo -e "\e[33mPress Enter to exit...\e[0m"
read -s