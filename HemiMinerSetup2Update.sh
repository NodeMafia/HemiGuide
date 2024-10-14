#!/bin/bash

# Node Mafia ASCII Art
echo "
     __             _                        __  _        
  /\ \ \  ___    __| |  ___   /\/\    __ _  / _|(_)  __ _ 
 /  \/ / / _ \  / _\` | / _ \ /    \  / _\` || |_ | | / _\` |
/ /\  / | (_) || (_| ||  __// /\/\ \| (_| ||  _|| || (_| |
\_\ \/   \___/  \__,_| \___|\/    \/ \__,_||_|  |_| \__,_|
                                                          
EN Telegram: soon..
RU Telegram: https://t.me/NodeMafia 
GitHub: https://github.com/NodeMafia
"

# Check for jq
if ! command -v jq &> /dev/null
then
    echo "jq is not installed. Installing jq..."
    sudo apt-get update
    sudo apt-get install -y jq
else
    echo "jq is already installed."
fi

# Function to update Hemi
update_hemi() {
    # Terminate the current screen session 'Hemi_nodeeval' (if running)
    echo "Terminating current screen session 'Hemi_nodeeval' (if it exists)..."
    screen -r Hemi_nodeeval -X quit || echo "Session 'Hemi_nodeeval' not found."

    # Remove the folder starting with heminetwork_v inside ~/HemiMiner/
    TARGET_DIR="$HOME/HemiMiner/"
    echo "Looking for folders starting with 'heminetwork_v' in $TARGET_DIR..."

    # List directories for debugging
    ls -l "$TARGET_DIR"

    FOLDER_TO_DELETE=$(find "$TARGET_DIR" -type d -name 'heminetwork_v*' -print -quit)

    if [ -n "$FOLDER_TO_DELETE" ]; then
        echo "Removing folder $FOLDER_TO_DELETE..."
        rm -rf "$FOLDER_TO_DELETE"
    else
        echo "Folder starting with 'heminetwork_v' not found."
    fi

    # Download the new version of Hemi
    echo "Downloading Hemi version 0.4.5..."
    wget https://github.com/hemilabs/heminetwork/releases/download/v0.4.5/heminetwork_v0.4.5_linux_amd64.tar.gz -P /tmp/

    # Create a directory with the name of the file without .tar.gz
    NEW_FOLDER_NAME="heminetwork_v0.4.5_linux_amd64"
    DESTINATION_DIR="$TARGET_DIR$NEW_FOLDER_NAME"
    mkdir -p "$DESTINATION_DIR"

    # Extract the archive using --strip-components=1
    echo "Extracting archive to $DESTINATION_DIR..."
    tar --strip-components=1 -xzvf /tmp/heminetwork_v0.4.5_linux_amd64.tar.gz -C "$DESTINATION_DIR"
}

# Function to start Hemi
start_hemi() {
    # Navigate to the folder HemiMiner/heminetwork_v0.4.5_linux_amd64/
    echo ""
    echo "Navigating to $HOME/HemiMiner/heminetwork_v0.4.5_linux_amd64/..."
    cd "$HOME/HemiMiner/heminetwork_v0.4.5_linux_amd64/" || { echo "Failed to navigate to directory. Exiting."; exit 1; }

    # Create and start a screen session
    echo "Creating and entering a new screen session named 'Hemi_nodeeval' and executing commands..."
    screen -S Hemi_nodeeval -dm bash -c "
        # Get variables from the popm-address.json file
        eval \$(jq -r '. | \"ETHEREUM_ADDRESS=\(.ethereum_address)\nNETWORK=\(.network)\nPRIVATE_KEY=\(.private_key)\nPUBLIC_KEY=\(.public_key)\nPUBKEY_HASH=\(.pubkey_hash)\"' ~/popm-address.json)

        # Export variables
        export POPM_BTC_PRIVKEY=\$PRIVATE_KEY
        export POPM_STATIC_FEE=200
        export POPM_BFG_URL=wss://testnet.rpc.hemi.network/v1/ws/public

        # Output variables for debugging inside screen
        echo \"Ethereum Address: \$ETHEREUM_ADDRESS\"
        echo \"Network: \$NETWORK\"
        echo \"Private Key: \$PRIVATE_KEY\"
        echo \"Public Key: \$PUBLIC_KEY\"
        echo \"Public Key Hash: \$PUBKEY_HASH\"

        # Instructions
        echo -e \"\n\033[31m!INSTRUCTIONS FOR USE!\033[0m\"
        echo -e \"\033[35mTo close the screen, use: CTRL+A+D\033[0m\"
        echo -e \"\033[35mTo open the screen for viewing logs: screen -r Hemi_nodeeval\033[0m\"
        echo -e \"\033[35mView list of screens: screen -ls\033[0m\"
        echo -e \"\033[35mTo stop HemiMiner: screen -r Hemi_nodeeval -X quit\033[0m\"

        # Confirmation with Enter key
        read -p \"Press Enter to continue and start popmd...\"

        # Start popmd
        ./popmd
    "

    # Connect to the screen session
    echo "Opening the screen session 'Hemi_nodeeval'..."
    screen -r Hemi_nodeeval
}

# Selection menu
echo "Please choose an option:"
echo "1. Start Hemi"
echo "2. Update Hemi to version 0.4.5, delete the folder, and start the miner"

read -p "Enter your choice (1 or 2): " choice

case $choice in
  1)
    start_hemi
    ;;
  2)
    update_hemi
    start_hemi
    ;;
  *)
    echo "Invalid choice. Exiting."
    ;;
esac
