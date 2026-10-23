output "ssh_command" {
  value = "ssh -i private-key/terraform-key.pem -p ${var.ssh_port} ec2-user@localhost"
}

output "web_url" {
  value = "http://localhost:${var.http_port}"
}

output "app1_urls" {
  value = [
    "http://localhost:${var.http_port}/app1/file1.html",
    "http://localhost:${var.http_port}/app1-v2/file1.html",
  ]
}
