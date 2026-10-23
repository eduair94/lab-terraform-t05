# Reemplaza el "terraform-key.pem" que el lab descargaba de AWS (y subia a git ❌).
# Terraform genera el par de claves; la publica va al servidor, la privada la usa el provisioner.
resource "tls_private_key" "terraform_key" {
  algorithm = "ED25519"
}

# Copia local para entrar por SSH a mano: ssh -i private-key/terraform-key.pem -p 2222 ec2-user@localhost
resource "local_sensitive_file" "terraform_key_pem" {
  content         = tls_private_key.terraform_key.private_key_openssh
  filename        = "${path.module}/private-key/terraform-key.pem"
  file_permission = "0400"
}
