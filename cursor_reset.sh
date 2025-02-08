#!/bin/bash

# Integrated Cursor Reset Script
# Combines ID regeneration and AppImage modification

# --------------------------
# Configuration
# --------------------------
APPIMAGE_PATH=""
STORAGE_PATH="$HOME/.config/Cursor/User/globalStorage/storage.json"
MACHINE_ID_PATH="$HOME/.config/Cursor/machineid"
TEMP_DIR=$(mktemp -d)
APPIMAGETOOL_PATH="/tmp/appimagetool"

# --------------------------
# Visual Elements
# --------------------------
LOGO="
   ██████╗██╗   ██╗██████╗ ███████╗ ██████╗ ██████╗ 
  ██╔════╝██║   ██║██╔══██╗██╔════╝██╔═══██╗██╔══██╗
  ██║     ██║   ██║██████╔╝███████╗██║   ██║██████╔╝
  ██║     ██║   ██║██╔══██╗╚════██║██║   ██║██╔══██╗
  ╚██████╗╚██████╔╝██║  ██║███████║╚██████╔╝██║  ██║
   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
"

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

# --------------------------
# Core Functions
# --------------------------

generate_uuid_v4() {
    uuid=$(uuidgen)
    uuid=${uuid:0:14}4${uuid:15}
    variant=(8 9 a b)
    random_variant=${variant[$RANDOM % 4]}
    uuid=${uuid:0:19}$random_variant${uuid:20}
    echo "$uuid"
}

setup_appimagetool() {
    echo -e "${YELLOW}Downloading appimagetool...${RESET}"
    
    URL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$(uname -m).AppImage"
    
    if command -v curl &> /dev/null; then
        curl -sL -o "$APPIMAGETOOL_PATH" "$URL" || return 1
    elif command -v wget &> /dev/null; then
        wget -O "$APPIMAGETOOL_PATH" "$URL" || return 1
    else
        echo -e "${RED}Error: Need curl or wget to download appimagetool${RESET}"
        return 1
    fi

    chmod +x "$APPIMAGETOOL_PATH" || return 1
    echo -e "${GREEN}AppImageTool installed successfully!${RESET}"
}

modify_appimage() {
    echo -e "${YELLOW}Starting AppImage modification...${RESET}"
    
    # Extract AppImage
    echo -e "${BLUE}Extracting AppImage...${RESET}"
    "$APPIMAGE_PATH" --appimage-extract >/dev/null || {
        echo -e "${RED}Failed to extract AppImage!${RESET}"
        return 1
    }

    # Modify files
    FILES=(
        "$TEMP_DIR/squashfs-root/resources/app/out/main.js"
        "$TEMP_DIR/squashfs-root/resources/app/out/vs/code/node/cliProcessMain.js"
    )

    for file in "${FILES[@]}"; do
        [ -f "$file" ] || continue
        echo -e "${BLUE}Modifying $file...${RESET}"
        sed -i 's/"[^"]*\/etc\/machine-id[^"]*"/"uuidgen"/g' "$file" || return 1
    done

    # Repack AppImage
    echo -e "${BLUE}Repacking AppImage...${RESET}"
    ARCH=x86_64 "$APPIMAGETOOL_PATH" -n ./squashfs-root >/dev/null 2>&1 || return 1

    # Replace original
    NEW_IMAGE=$(ls -t Cursor-*.AppImage 2>/dev/null | head -n1)
    [ -z "$NEW_IMAGE" ] && return 1
    mv -f "$NEW_IMAGE" "$APPIMAGE_PATH" || return 1

    echo -e "${GREEN}AppImage successfully modified!${RESET}"
}

# --------------------------
# Main Execution
# --------------------------

# Display header
clear
echo -e "${BLUE}$LOGO${RESET}"
echo -e "${YELLOW}=== Cursor Telemetry Reset Tool ===${RESET}"
echo ""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --appimage)
            APPIMAGE_PATH="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate inputs
[ -z "$APPIMAGE_PATH" ] && { echo -e "${RED}AppImage path required! Use --appimage option${RESET}"; exit 1; }
[ ! -f "$APPIMAGE_PATH" ] && { echo -e "${RED}AppImage not found at: $APPIMAGE_PATH${RESET}"; exit 1; }

# Check dependencies
for cmd in jq uuidgen; do
    command -v $cmd &> /dev/null || {
        echo -e "${RED}Missing required command: $cmd${RESET}"
        exit 1
    }
done

# Generate new IDs
echo -e "${YELLOW}Generating new identifiers...${RESET}"
new_machineId=$(generate_uuid_v4)
new_macMachineId=$(generate_uuid_v4)
new_devDeviceId=$(generate_uuid_v4)
new_sqmId=$(generate_uuid_v4)
new_machine_id=$(generate_uuid_v4)

# Backup and update storage.json
echo -e "${YELLOW}Updating configuration files...${RESET}"
[ -f "$STORAGE_PATH" ] && cp "$STORAGE_PATH" "${STORAGE_PATH}.bak"
echo "$(jq \
    --arg mid "$new_machineId" \
    --arg mmid "$new_macMachineId" \
    --arg did "$new_devDeviceId" \
    --arg sid "$new_sqmId" \
    '.["telemetry.machineId"] = $mid |
     .["telemetry.macMachineId"] = $mmid |
     .["telemetry.devDeviceId"] = $did |
     .["telemetry.sqmId"] = $sid' \
    "$STORAGE_PATH")" > "$STORAGE_PATH"

# Update machine ID file
echo "$new_machine_id" > "$MACHINE_ID_PATH"

# Modify AppImage
cd "$TEMP_DIR" || exit 1
if [ ! -f "$APPIMAGETOOL_PATH" ]; then
    setup_appimagetool || { rm -rf "$TEMP_DIR"; exit 1; }
fi

modify_appimage || {
    echo -e "${RED}AppImage modification failed!${RESET}"
    rm -rf "$TEMP_DIR"
    exit 1
}

# Cleanup
rm -rf "$TEMP_DIR"
echo -e "${GREEN}✅ All operations completed successfully!${RESET}"
echo -e "${YELLOW}Please restart Cursor using the modified AppImage.${RESET}"