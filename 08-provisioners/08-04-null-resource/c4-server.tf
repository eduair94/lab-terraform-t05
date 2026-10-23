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
}

# Wait for 10 seconds after creating the above server (en EC2: 90s para que termine user_data)
resource "time_sleep" "wait_10_seconds" {
  depends_on      = [docker_container.my-ec2-vm]
  create_duration = "10s"
}

# Sync App1 Static Content to Webserver using Provisioners
# null_resource no crea nada: es solo un "contenedor" de provisioners con triggers.
resource "null_resource" "sync_app1_static" {
  depends_on = [time_sleep.wait_10_seconds]
  triggers = {
    always-update = timestamp() # cambia SIEMPRE -> se recrea (y re-ejecuta) en cada apply
  }

  # Connection Block for Provisioners to connect to the server
  connection {
    type        = "ssh"
    host        = "127.0.0.1"
    port        = var.ssh_port
    user        = "ec2-user"
    private_key = tls_private_key.terraform_key.private_key_openssh
  }

  # Copies the app1 folder to /tmp
  provisioner "file" {
    source      = "apps/app1"
    destination = "/tmp"
  }

  # Copies the /tmp/app1 folder to Apache Webserver /var/www/html directory
  provisioner "remote-exec" {
    inline = [
      "sudo cp -r /tmp/app1 /var/www/html",
    ]
  }
}

# Alternativa moderna (Terraform >= 1.4): terraform_data es built-in, no necesita el provider "null".
# Ademas, en vez de timestamp() usamos un HASH del contenido: solo re-sincroniza si cambio algun archivo.
resource "terraform_data" "sync_app1_on_change" {
  depends_on = [time_sleep.wait_10_seconds]
  triggers_replace = sha1(join("", [
    for f in fileset("${path.module}/apps/app1", "**") : filesha1("${path.module}/apps/app1/${f}")
  ]))

  connection {
    type        = "ssh"
    host        = "127.0.0.1"
    port        = var.ssh_port
    user        = "ec2-user"
    private_key = tls_private_key.terraform_key.private_key_openssh
  }

  # Carpeta propia: null_resource y terraform_data corren EN PARALELO;
  # si los dos copian a /tmp/app1 a la vez, scp falla con "File exists".
  provisioner "remote-exec" {
    inline = ["mkdir -p /tmp/v2"]
  }

  provisioner "file" {
    source      = "apps/app1"
    destination = "/tmp/v2"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /var/www/html/app1-v2",
      "sudo cp -r /tmp/v2/app1 /var/www/html/app1-v2",
    ]
  }
}
