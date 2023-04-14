# Outputs
output "public_ec2_ips" {
  description = "List of public IP addresses assigned to the instances"
  value = {
    dev1-1 = aws_instance.dev-1.*.public_ip,
    prod-1 = aws_instance.prod-1.*.public_ip,
    prod-2 = aws_instance.prod-2.*.public_ip
  }
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.lb.dns_name
}

output "efs_ip_address_prod1" {
  description = "prod1 EFS ip address"
  value       = aws_efs_mount_target.efs_mount1.ip_address
}

output "efs_ip_address_prod2" {
  description = "prod2 EFS ip address"
  value       = aws_efs_mount_target.efs_mount2.ip_address
}
