#!/bin/bash
set -e

AGENT_VERSION="5.277.0"
ADO_ORG_URL="https://dev.azure.com/your-org"
AGENT_POOL="your-pool-name"
AGENT_NAME=$(hostname)

# Create installation directory
sudo mkdir -p /opt/azdo-agent
sudo chown $USER:$USER /opt/azdo-agent
cd /opt/azdo-agent

# Download and extract the agent
wget -q https://download.agent.dev.azure.com/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz
tar zxf vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz

# Configure the agent (non-interactive)
./config.sh \
  --unattended \
  --url "$ADO_ORG_URL" \
  --auth pat \
  --token "$1" \
  --pool "$AGENT_POOL" \
  --agent "$AGENT_NAME" \
  --acceptTeeEula

# Install and start as a service
sudo ./svc.sh install
sudo ./svc.sh start

# Install required tools
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo apt install -y git jq unzip
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

# Verify
sudo ./svc.sh status
echo "Agent setup complete"