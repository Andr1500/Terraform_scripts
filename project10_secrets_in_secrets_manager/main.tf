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
  password             = data.aws_secretsmanager_secret_version.rds_pass.secret_string
}

#the resource for generating passwords for our instances
resource "random_password" "generate_pass" {
  length           = 20
  special          = true    #using spec. characters
  override_special = "!#$%&" #the chatacters which I need to use
}

#store password
resource "aws_secretsmanager_secret" "rds_pass" {
  name                    = "/prod/rds/password/"
  description             = "Password for RDS DB"
  recovery_window_in_days = 0 #specifies how many days Secrets Manager waits before it can delete the secret
}

resource "aws_secretsmanager_secret_version" "rds_pass" {
  secret_id     = aws_secretsmanager_secret.rds_pass.id
  secret_string = random_password.generate_pass.result
}

#store all RDS parameters
resource "aws_secretsmanager_secret" "rds" {
  name                    = "/prod/rds/all/"
  description             = "All details for RDS DB"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    rds_address  = aws_db_instance.prod.address
    rds_port     = aws_db_instance.prod.port
    rds_username = aws_db_instance.prod.username
  })
}

#retreive password
data "aws_secretsmanager_secret_version" "rds_pass" {
  secret_id  = aws_secretsmanager_secret.rds_pass.id
  depends_on = [aws_secretsmanager_secret_version.rds_pass]
}

#retreive ALL
data "aws_secretsmanager_secret_version" "rds" {
  secret_id  = aws_secretsmanager_secret.rds.id
  depends_on = [aws_secretsmanager_secret_version.rds]
}


#outputs
output "rds_address" {
  value = aws_db_instance.prod.address
}

output "rds_port" {
  value = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["rds_port"])
}

output "rds_username" {
  value = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["rds_username"])
}


output "rds_all" {
  value = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string))
}
