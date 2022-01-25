variable "aws_region" {
  description = "The region where you want to provision EC2 web server"
  type        = string
  default     = "eu-central-1"
}

variable "port_list" {
  description = "list of ports"
  type        = list(any)
  default     = ["80", "443"]
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

variable "tags" {
  description = "tags to apply resources"
  type        = map(any)
  default = {
    Owner       = "a1500"
    Environment = "Prod"
  }
}

#variable "key_pair" {
#  description = "SSH key pair name to input it into EC2"
#  type        = string
#  default     = "FrankfurtKey"
#  sensitive   = true
#}

variable "password" {
  description = "Please Enter Password lenght of 10 characters!"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.password) == 10
    error_message = "Your Password must be 10 characted exactly!!!"
  }
}
