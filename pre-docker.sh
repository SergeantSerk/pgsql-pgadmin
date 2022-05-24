#!/bin/bash
echo "Performing system update..."
sudo apt update
sudo apt upgrade --yes

echo "Installing required packages for Docker..."
sudo apt install --yes ca-certificates curl gnupg lsb-release

echo "Importing Docker repository and keys..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

echo "Installing Docker..."
sudo apt install --yes docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $(echo $USER)

echo "Restart session and continue from post-docker.sh"