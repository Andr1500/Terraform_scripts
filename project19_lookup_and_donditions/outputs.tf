output "server_id" {
  value = aws_instance.server1.id
}

output "server_public_ip" {
  value = aws_instance.server1.public_ip
}
