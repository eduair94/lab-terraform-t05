output "ssh_command" {
  value = "ssh -i private-key/terraform-key.pem -p ${var.ssh_port} ec2-user@localhost"
}

output "web_url" {
  value = "http://localhost:${var.http_port}"
}

output "file_url" {
  value = "http://localhost:${var.http_port}/file-copy.html"
}
