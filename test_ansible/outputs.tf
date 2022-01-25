output "Amazon_Linux_Server" {
  value = {
    for droplet in aws_instance.ansible_amazon_linux :
    droplet.tags.Name => droplet.public_ip
  }
}

output "Ubuntu_Linux_Server" {
  value = {
    for droplet in aws_instance.ansible_ubuntu_linux :
    droplet.tags.Name => droplet.public_ip
  }
}
