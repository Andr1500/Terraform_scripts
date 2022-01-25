provider "aws" {
  region = "us-west-1"
}

provider "aws" {
  region = "us-west-1"
  alias  = "EUROPE"
}

provider "aws" {
  region = "us-west-1"
  alias  = "ASIA"
}

#==================================================================

data "aws_ami" "defaut_latest_ubuntu20" {
  owners      = ["138161713046"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_ami" "europe_latest_ubuntu20" {
  provider    = aws.EUROPE
  owners      = ["138161713046"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_ami" "asia_latest_ubuntu20" {
  provider    = aws.ASIA
  owners      = ["138161713046"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}



output "ids" {
  value = data.aws_ami.defaut_latest_ubuntu20.id
}
