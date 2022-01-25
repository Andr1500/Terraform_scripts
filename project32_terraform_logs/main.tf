/*
log levels:
TRACE (by default, all the information)
DEBUG
INFO
WARN
ERROR
for providing only INFO logs, type export TF_LOG=INFO
*/

provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "web" {
  ami           = "ami-047e03b8591f2d48a" // Amazon Linux2
  instance_type = "t3.micro"

}
