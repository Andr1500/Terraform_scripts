#variables
variable "region" {
  default = "eu-central-1"
}

variable "az" {
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "instance_type" {
  default = "t3.micro"
}

