provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  region = "eu-south-1"
  alias  = "DEV"

  assume_role { #the role for another aws account
    role_arn = "arn:aws:iam::138161713046:role/terraformrole"
  }
}

#------------------
resource "aws_vpc" "master_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "master VPC"
  }
}

resource "aws_vpc" "dev_vpc" {
  provider   = aws.DEV
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev VPC"
  }
}
