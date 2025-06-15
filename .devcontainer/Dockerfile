# Use the base Ubuntu devcontainer image.
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install additional packages.
RUN apt-get update && \
    apt-get install -y curl software-properties-common ca-certificates

RUN update-ca-certificates

# Install Packer
RUN sudo mkdir -m 0755 -p /etc/apt/keyrings/ && \ 
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/hashicorp-packer.gpg && \
    sudo echo "deb [arch=amd64, signed-by=/etc/apt/keyrings/hashicorp-packer.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp-packer.list > /dev/null && \
    sudo chmod 0644 /etc/apt/keyrings/hashicorp-packer.gpg && \
    sudo apt-get update && sudo apt-get install packer

# Install Python3 and Ansible.
RUN add-apt-repository --yes --update ppa:ansible/ansible && \
    apt-get update && \
    apt-get install -y python3 python3-pip ansible

# Cleanup.
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set PATH
ENV PATH="$HOME/.local/bin:$PATH"