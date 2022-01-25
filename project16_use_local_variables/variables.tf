variable "environment" {
  default = "DEV"
}

variable "project_name" {
  default = "Unicorn"
}

variable "owner" {
  default = "a1500"
}

variable "tags" {
  default = {
    budged_code = 11223344
    Manager     = "Elon Mask"
    Planet      = "Mars"
  }
}
