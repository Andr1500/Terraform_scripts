provider "aws" {
  region = "eu-north-1"
}

module "vpc_prod" {
  #source               = "../modules/aws_network"
  source               = "git@github.com:Andr1500/terraform_modules.git//aws_network"
  env                  = "prod"
  vpc_cidr             = "10.20.0.0/16"
  public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
  private_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24", "10.20.13.0/24"]
  tags = {
    Owner   = "A1500"
    Code    = "123456"
    Project = "Oxygen"
  }
}

module "server_standalone" {
  #source    = "../modules/aws_webserver"
  source    = "git@github.com:Andr1500/terraform_modules.git//aws_webserver"
  name      = "a1500"
  message   = "stand alone server"
  subnet_id = module.vpc_prod.public_subnet_ids[1]
}

module "server_loop_count" {
  #source    = "../modules/aws_webserver"
  source    = "git@github.com:Andr1500/terraform_modules.git//aws_webserver"
  count     = length(module.vpc_prod.public_subnet_ids)
  name      = "a1500"
  message   = "Server in the Subnet ${module.vpc_prod.public_subnet_ids[count.index]} created by COUNT LOOP"
  subnet_id = module.vpc_prod.public_subnet_ids[count.index]
}
