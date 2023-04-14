
variable "region" {
  description = "The aws region"
  type        = string
  default     = "eu-central-1"
}

variable "availability_zones_count" {
  description = "The number of AZs."
  type        = number
  default     = 2
}

variable "project" {
  description = "mern-app"
  type        = string
  default     = "mern-app"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_bits" {
  description = "The number of subnet bits for the CIDR. For example, specifying a value 8 for this parameter will create a CIDR with a mask of /24."
  type        = number
  default     = 8
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    "Project"     = "MERN-app"
    "Environment" = "Development"
    "Owner"       = "a1500"
  }
}

variable "docdb_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "docdb_username" {
  type    = string
  default = "docdbadmin"
}

variable "docdb_password" {}
