#!/bin/bash

# Node Mafia ASCII Art
echo "
     __             _                        __  _        
  /\ \ \  ___    __| |  ___   /\/\    __ _  / _|(_)  __ _ 
 /  \/ / / _ \  / _\` | / _ \ /    \  / _\` || |_ | | / _\` |
/ /\  / | (_) || (_| ||  __// /\/\ \| (_| ||  _|| || (_| |
\_\ \/   \___/  \__,_| \___|\/    \/ \__,_||_|  |_| \__,_|
                                                          
EN Telegram: soon..
RU Telegram: https://t.me/SixThoughtsLines
GitHub: https://github.com/NodeMafia
"

# Check if jq is installed, if not install it
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing jq..."
    sudo apt update
    sudo apt install -y jq
fi

# Create directory and navigate into it
echo ""
echo "Creating directory and navigating into it..."
mkdir HemiMiner && cd HemiMiner

# Download the required archive
echo ""
echo "Downloading the required archive..."
wget https://github.com/hemilabs/heminetwork/releases/download/v0.4.3/heminetwork_v0.4.3_linux_amd64.tar.gz

# Unpack the archive
echo ""
echo "Unpacking the archive..."
tar -zxvf heminetwork_v0.4.3_linux_amd64.tar.gz 

# Remove the archive
echo ""
echo "Removing the archive..."
rm heminetwork_v0.4.3_linux_amd64.tar.gz 

# Navigate into the unpacked directory
echo ""
echo "Navigating into the unpacked directory..."
cd heminetwork_v0.4.3_linux_amd64/

# Check the contents of the directory
echo ""
echo "Checking the contents of the directory..."
ls

# Make the popmd file executable
echo ""
echo "Making the popmd file executable..."
chmod +x ./popmd

# Display help
echo ""
echo "Displaying help..."
./popmd --help

# Generate keys and save to JSON file
echo ""
echo "Generating keys and saving to JSON file..."
./keygen -secp256k1 -json -net="testnet" > ~/popm-address.json

# Check the contents of the JSON file
echo ""
echo "Checking the contents of the JSON file..."
cat ~/popm-address.json

# Automatically assign variables from JSON
echo ""
echo "Automatically assigning variables from JSON..."
eval $(jq -r '. | "ETHEREUM_ADDRESS=\(.ethereum_address)\nNETWORK=\(.network)\nPRIVATE_KEY=\(.private_key)\nPUBLIC_KEY=\(.public_key)\nPUBKEY_HASH=\(.pubkey_hash)"' ~/popm-address.json)

# Display the variables
echo ""
echo "Displaying variables..."
echo "Ethereum Address: $ETHEREUM_ADDRESS"
echo "Network: $NETWORK"
echo "Private Key: $PRIVATE_KEY"
echo "Public Key: $PUBLIC_KEY"
echo "Public Key Hash: $PUBKEY_HASH"

# Export environment variables
echo ""
echo "Exporting environment variables..."
export POPM_BTC_PRIVKEY=$PRIVATE_KEY
export POPM_STATIC_FEE=50
export POPM_BFG_URL=wss://testnet.rpc.hemi.network/v1/ws/public

# Instructions for tBTC request
echo ""
echo "1. Join the Hemi Discord 'https://discord.gg/hemixyz' and request tBTC in the faucet channel with the command /tbtc-faucet to the wallet at this address: $PUBKEY_HASH"
echo "2. Check here if your Bitcoin has arrived: 'https://mempool.space/testnet/address/$PUBKEY_HASH'"
