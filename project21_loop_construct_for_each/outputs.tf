output "user_arns" {
  value = values(aws_iam_user.user)[*].arn
}

output "prod_instance_id" {
  value = aws_instance.servers["prod"].id
}

output "instances_ids" {
  value = values(aws_instance.servers)[*].id
}

output "instance_public_ips" {
  value = values(aws_instance.servers)[*].public_ip
}

output "bastion_public_ip" {
  value = var.create_bastion_server == "yes" ? aws_instance.bastionServer["bastion"].public_ip : null
}
