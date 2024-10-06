#!/bin/bash

# Display the logo
curl -s https://raw.githubusercontent.com/zunxbt/logo/main/logo.sh | bash
sleep 3

# Function to display messages in blue
show() {
    echo -e "\n\e[1;34m$1\e[0m\n"
}

# Check if Git is installed, if not, install it
if ! command -v git &> /dev/null; then
    show "Git is not installed. Installing Git..."
    sudo apt-get update && sudo apt-get install -y git || {
        echo "Git installation failed."
        exit 1
    }
else
    show "Git is already installed."
fi

# Install npm using external script
show "Installing npm..."
source <(wget -qO- https://raw.githubusercontent.com/zunxbt/installation/main/node.sh) || {
    echo "Npm installation failed."
    exit 1
}

# Remove existing Story-Protocol directory if it exists
if [ -d "Story-Protocol" ]; then
    show "Removing existing Story-Protocol directory..."
    rm -rf Story-Protocol || {
        echo "Failed to remove existing Story-Protocol directory."
        exit 1
    }
fi

# Clone the Story-Protocol repository
show "Cloning Story-Protocol repository..."
git clone https://github.com/zunxbt/Story-Protocol.git && cd Story-Protocol || {
    echo "Failed to clone the repository."
    exit 1
}

# Install npm dependencies
show "Installing npm dependencies..."
npm install || {
    echo "Failed to install npm dependencies."
    exit 1
}

# Get input from the user securely
read -s -p "Enter your wallet private key: " WALLET_PRIVATE_KEY
echo
read -p "Enter Pinata JWT token: " PINATA_JWT

# Create or update the .env file
cat <<EOF > .env
WALLET_PRIVATE_KEY=$WALLET_PRIVATE_KEY
PINATA_JWT=$PINATA_JWT
EOF

show "Running npm script to create SPG collection..."
npm run create-spg-collection || {
    echo "Failed to create SPG collection."
    exit 1
}

# Get NFT contract address from the user
read -p "Enter NFT contract address: " NFT_CONTRACT_ADDRESS

# Append the contract address to the .env file
echo "NFT_CONTRACT_ADDRESS=$NFT_CONTRACT_ADDRESS" >> .env

show "Running npm script for metadata generation..."
npm run metadata || {
    echo "Metadata generation failed."
    exit 1
}

show "Process complete!"
