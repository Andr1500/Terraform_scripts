variable "users" {
  type = set(string)
  default = [
    "Jim",
    "Mike",
    "Todd",
    "Jeff",
    "Randy",
    "Susmitha"
  ]
}

variable "readonly_users" {
  type = set(string)
  default = [
    "Chris",
    "Pete",
    "Justin"
  ]
}

variable "backend_server_ips" {
  type = set(string)
  default = [
    "ip_addr_1",
    "ip_addr_2",
  ]
}

variable "backend_windows_server_ips" {
  type = set(string)
  default = [
    "ip_addr_1",
  ]
}
