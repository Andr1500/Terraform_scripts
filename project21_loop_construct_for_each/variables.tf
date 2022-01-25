variable "aws_users" {
  description = "emails of IAM users"
  default = [
    "vasia@ad.com",
    "petia@ad.com",
    "sania@ad.com",
    #"fedia@as.com",
    "vova@sd.com"
  ]
}

variable "server_settings" {
  type = map(any)
  default = {
    web = {
      ami            = "ami-07df274a488ca9195"
      instance_type  = "t3.small"
      root_disk_size = 20
      encrypted      = true
    }
    app = {
      ami            = "ami-06ec8443c2a35b0ba"
      instance_type  = "t3.micro"
      root_disk_size = 10
      encrypted      = false
    }
  }
}

variable "create_bastion_server" {
  description = "provision bastion server yes/no"
  default     = "yep"
}
