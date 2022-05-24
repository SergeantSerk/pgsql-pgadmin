#!/bin/bash
NC='\033[0m'
RED='\033[1;31m'

echo -e "${RED}Performing system update...${NC}"
sudo apt update
sudo apt upgrade --yes

echo -e "${RED}Installing required packages for Docker...${NC}"
sudo apt install --yes ca-certificates curl gnupg lsb-release

echo -e "${RED}Importing Docker repository and keys...${NC}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo -e "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

echo -e "${RED}Installing Docker...${NC}"
sudo apt install --yes docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $(echo $USER)

echo -e "${RED}Restart session and continue from post-docker.sh${NC}"