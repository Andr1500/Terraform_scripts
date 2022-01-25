variable "server_name" {
  description = "Name for WebServer"
  type        = string
  default     = "prod"

}


variable "server_size" {
  description = "Server Size for WebServer"
  type        = string
  default     = "t3.micro"
}
