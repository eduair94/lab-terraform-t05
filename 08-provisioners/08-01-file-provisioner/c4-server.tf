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

  # Copies the file-copy.html file to /tmp/file-copy.html
  provisioner "file" {
    source      = "apps/file-copy.html"
    destination = "/tmp/file-copy.html"
  }

  # Copies the string in content into /tmp/file.log
  provisioner "file" {
    content     = "image used: ${self.image}" # "self" de nuevo (en EC2: self.ami)
    destination = "/tmp/file.log"
  }

  # Copies the app1 folder to /tmp - FOLDER COPY -> /tmp/app1/...
  provisioner "file" {
    source      = "apps/app1"
    destination = "/tmp"
  }

  # Copies all files and folders in apps/app2 to /tmp - CONTENTS of FOLDER WILL BE COPIED
  provisioner "file" {
    source      = "apps/app2/" # con "/" al final se copia el CONTENIDO, no la carpeta
    destination = "/tmp"
  }

  /*
  # Paso 05 - Failure Behavior: ec2-user NO tiene permiso de escritura en /var/www/html
  provisioner "file" {
    source      = "apps/file-copy.html"
    destination = "/var/www/html/file-copy.html"
    #on_failure  = continue # Test-2: descomentar
  }
  */

}
