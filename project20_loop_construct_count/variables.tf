variable "aws_users" {
  description = "emails of IAM users"
  default = [
    "vasia@ad.com",
    "petia@ad.com",
    "sania@ad.com",
    "fedia@as.com",
    "vova@sd.com"
  ]
}

variable "create_bastion" {
  description = "provision bastion server yes/no"
  default     = "no"
}
