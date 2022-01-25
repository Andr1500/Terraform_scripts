output "instances_ids" {
  value = aws_instance.server1[*].id
}

output "instances_public_ips" {
  value = aws_instance.server1[*].public_ip
}
output "server_id_ip" {
  value = [
    for x in aws_instance.server1 :
    "Server with ID: ${x.id} has Public IP: ${x.public_ip}"
  ]
}

output "server_id_ip_map" {
  value = {
    for x in aws_instance.server1 :
    x.id => x.public_ip #something like "i-1234567890" = "192.168.10.1"
  }
}


output "users_unique_id_arm" {
  value = [
    for user in aws_iam_user.user :
    "User_ID ${user.unique_id} has ARN: ${user.arn}"
  ] #aws_iam_user.user
}

output "user_unique_id_name_custom" {
  value = {
    for user in aws_iam_user.user :
    user.unique_id => user.name
    if length(user.name) < 10
  }
}
