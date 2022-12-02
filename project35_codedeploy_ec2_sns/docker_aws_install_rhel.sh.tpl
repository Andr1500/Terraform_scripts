#!/bin/bash
# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done
#update system and install docker
# sudo yum update -y
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io -y
sudo systemctl start docker.service
sudo systemctl enable docker.service
#install unzip
sudo yum install unzip -y
#install awssli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo chmod 666 /var/run/docker.sock
#install codedeploy agent
sudo yum install wget -y
sudo yum -y install ruby
wget https://aws-codedeploy-${default_region}.s3.${default_region}.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo systemctl start codedeploy-agent.service
sudo systemctl enable codedeploy-agent.service
