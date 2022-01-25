output "instance_ids" {
  value = aws_instance.serverLinux[*].id
}

output "instance_public_ips" {
  value = aws_instance.serverLinux[*].public_ip
}

output "iam_users_arm" {
  value = aws_iam_user.user[*].arn
}

output "bastionServer_piblic_ip" {
  value = var.create_bastion == "yes" ? aws_instance.bastionServer[0].public_ip : null
  #creating output only if conditions is "yes", if condition is another -> putting null
}
