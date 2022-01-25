provider "aws" {
  region = "eu-central-1"
}


module "my_vpc_default" {
  source = "../modules/aws_network"
}

module "my_vpc_prod" {
  source               = "../modules/aws_network"
  env                  = "prod"
  vpc_cidr             = "10.20.0.0/16"
  public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24"]
  tags = {
    Owner = "a1500"
    Code  = "123456"
  }
}
