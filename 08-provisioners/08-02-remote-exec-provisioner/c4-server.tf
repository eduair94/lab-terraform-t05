# "EC2" falsa: contenedor Alpine con OpenSSH + usuario ec2-user con sudo
resource "docker_image" "server" {
  name         = "lscr.io/linuxserver/openssh-server:10.3_p1-r1-ls239"
  keep_locally = true
}

resource "docker_container" "my-ec2-vm" {
  name  = "my-ec2-vm"
  image = docker_image.server.image_id
  env = [
    "USER_NAME=ec2-user",
    "PUBLIC_KEY=${tls_private_key.terraform_key.public_key_openssh}",
    "SUDO_ACCESS=true", # sudo sin password (como ec2-user en Amazon Linux)
    "PASSWORD_ACCESS=false",
  ]
  ports {
    internal = 2222 # sshd de la imagen escucha en 2222
    external = var.ssh_port
  }
  ports {
    internal = 80
    external = var.http_port
  }

  # Equivalente a user_data = file("apache-install.sh")
  upload {
    file       = "/custom-cont-init.d/apache-install.sh"
    source     = "${path.module}/apache-install.sh"
    executable = true
  }

  # Connection Block: como se conectan los provisioners al servidor
  connection {
    type        = "ssh"
    host        = "127.0.0.1"
    port        = var.ssh_port # en EC2: host = self.public_ip ("self" = este mismo recurso)
    user        = "ec2-user"
    private_key = tls_private_key.terraform_key.private_key_openssh
  }

  # 1) Copies the file-copy.html file to /tmp/file-copy.html
  provisioner "file" {
    source      = "apps/file-copy.html"
    destination = "/tmp/file-copy.html"
  }

  # 2) Copies the file to Apache Webserver /var/www/html directory (necesita sudo)
  provisioner "remote-exec" {
    inline = [
      # En EC2 real: "sleep 120" para esperar que user_data termine de instalar Apache.
      # Aca esperamos a que exista el directorio, que es mas preciso que un sleep fijo.
      "while [ ! -d /var/www/html ]; do sleep 1; done",
      "sudo cp /tmp/file-copy.html /var/www/html",
    ]
  }
}
