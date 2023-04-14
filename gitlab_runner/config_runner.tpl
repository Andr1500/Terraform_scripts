#!/bin/bash

sudo apt update
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt install -y gitlab-runner
sudo gitlab-runner register -n \
  --url https://gitlab.com/ \
  --registration-token ${registration_token} \
  --executor shell \
  --description "Shell Runner Ubuntu" \
  --tag-list "shell" \
  --run-untagged \
  --locked false
sudo gitlab-runner restart

# terraform installation
sudo apt update && sudo apt install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform=1.4.2

# infracost installation
# Downloads the CLI based on your OS/arch and puts it in /usr/local/bin
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# TFlint installation
sudo apt install unzip
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# TFsec installation
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash