# Version AWS REAL de 08-01/08-02 (la que corre el lab original).
# No se puede probar con moto: sus "instancias" no tienen SSH. Solo: terraform init && terraform validate
# Sin pasos manuales: Terraform genera la clave y la registra en AWS (no hay .pem que subir a git).
resource "tls_private_key" "terraform_key" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-key"
  public_key = tls_private_key.terraform_key.public_key_openssh
}

resource "aws_instance" "my-ec2-vm" {
  ami                    = data.aws_ami.amzlinux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.terraform_key.key_name
  user_data              = file("apache-install.sh")
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]
  tags = {
    "Name" = "provisioners-demo"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = tls_private_key.terraform_key.private_key_openssh
  }

  provisioner "file" {
    source      = "apps/file-copy.html"
    destination = "/tmp/file-copy.html"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 120", # espera que user_data instale Apache
      "sudo cp /tmp/file-copy.html /var/www/html",
    ]
  }
}
