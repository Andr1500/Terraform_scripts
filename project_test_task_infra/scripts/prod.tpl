#!/bin/bash

sudo apt update
sudo apt install -y nginx
sudo sh -c 'hostname > /var/www/html/index.nginx-debian.html'
sudo systemctl start nginx
sudo systemctl enable nginx
sudo apt install -y nfs-common
sudo mkdir /mnt/efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${ip_address}:/ /mnt/efs