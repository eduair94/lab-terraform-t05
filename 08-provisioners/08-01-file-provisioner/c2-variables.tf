variable "ssh_port" {
  description = "Puerto del host que apunta al SSH (22) del servidor"
  type        = number
  default     = 2222
}

variable "http_port" {
  description = "Puerto del host que apunta al Apache (80) del servidor"
  type        = number
  default     = 8080
}
