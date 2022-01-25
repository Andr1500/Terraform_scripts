provider "aws" {
  region = "eu-central-1"
}

resource "aws_db_instance" "prod" {       #creating DB instance
  identifier           = "prod-mysql-rds" #RDS - relational database service
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  apply_immediately    = true
  username             = "administrator"
  password             = data.aws_ssm_parameter.rds_pass.value
}

#the resource for generating passwords for our instances
resource "random_password" "generate_pass" {
  length           = 20
  special          = true    #using spec. characters
  override_special = "!#$%&" #the chatacters which I need to use

}

#the resource for storing passwords
resource "aws_ssm_parameter" "rds_pass" {
  name        = "/prod/prod-mysql-rds/rds_pass"
  description = "master pass for RDS DB"
  type        = "SecureString"
  value       = random_password.generate_pass.result
}

#retrive password
data "aws_ssm_parameter" "rds_pass" {
  name       = "/prod/prod-mysql-rds/rds_pass"
  depends_on = [aws_ssm_parameter.rds_pass]
}

#outputs
output "rds_address" {
  value = aws_db_instance.prod.address
}

output "rds_port" {
  value = aws_db_instance.prod.port
}

output "rds_username" {
  value = aws_db_instance.prod.username
}

output "rds_password" {
  value     = data.aws_ssm_parameter.rds_pass.value
  sensitive = true
}
