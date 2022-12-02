#!/bin/bash
# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done
#update system and install docker
apt-get update -y
sudo snap install docker
sudo systemctl start docker.servicell
sudo systemctl enable docker.service
#install unzip
sudo apt install unzip -y
#install awssli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo chmod 666 /var/run/docker.sock
#install codedeploy agent
wget https://aws-codedeploy-${default_region}.s3.${default_region}.amazonaws.com/latest/install
sudo chmod +x ./install
sudo apt -y install ruby
sudo ./install auto
sudo systemctl start codedeploy-agent.service
sudo systemctl enable codedeploy-agent.service
#install apache web Server
sudo apt install apache2 -y
