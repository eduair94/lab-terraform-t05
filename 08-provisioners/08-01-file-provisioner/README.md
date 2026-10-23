# 08-01 · File Provisioner + Connection

> **En una frase:** `file` copia archivos de tu máquina al servidor por SSH, usando el bloque `connection`.

## 🧠 Lo esencial
```hcl
connection {                       # uno para todos los provisioners del recurso
  type        = "ssh"
  host        = "127.0.0.1"        # en EC2: self.public_ip
  port        = var.ssh_port
  user        = "ec2-user"
  private_key = tls_private_key.terraform_key.private_key_openssh
}

provisioner "file" {
  content     = "image used: ${self.image}"   # "self" = el recurso padre. No puedes usar
  destination = "/tmp/file.log"               # docker_container.my-ec2-vm (sería un ciclo)
}
```
**La barra final cambia todo:**
| `source` | Resultado en `/tmp` |
|---|---|
| `"apps/app1"` | copia la **carpeta** → `/tmp/app1/...` |
| `"apps/app2/"` | copia el **contenido** → `/tmp/app2-file1.html`, `/tmp/app2-folder-1/...` |

## ▶️ Ejecutar (sin AWS, con Docker)
```bash
terraform init && terraform apply -auto-approve
ssh -i private-key/terraform-key.pem -p 2222 ec2-user@localhost   # o: docker exec -it my-ec2-vm sh
ls -lR /tmp && cat /tmp/file.log
curl http://localhost:8080                                       # el "Apache" del user_data
```

## 👀 Salida real
```text
docker_container.my-ec2-vm: Provisioning with 'file'...   (x4)
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

/tmp:
drwxr-xr-x  app1                 <- "apps/app1"  (carpeta)
-rw-r--r--  app2-file1.html      <- "apps/app2/" (contenido)
-rw-r--r--  app2-file2.html
drwxr-xr-x  app2-folder-1
-rw-r--r--  file-copy.html
-rw-r--r--  file.log             -> "image used: sha256:0f535b0faa74..."
```

## 🧪 Paso 05: Failure behavior (`on_failure`)
Descomenta el bloque que copia a `/var/www/html` (es de root; `ec2-user` no puede escribir ahí):
```text
# Test-1: sin on_failure (= fail)
Error: file provisioner error
Upload failed: scp: /var/www/html/file-copy.html: Permission denied

$ grep '"status"' terraform.tfstate
          "status": "tainted",                 <- marcado para recrearse

# Test-2: on_failure = continue
  # docker_container.my-ec2-vm is tainted, so must be replaced
Apply complete! ...                            <- el error se ignora y el recurso NO queda tainted
```
🎁 Nos pasó de verdad mientras armábamos el lab: un puerto mal configurado hizo fallar el SSH, y el siguiente `plan` mostró `is tainted, so must be replaced`.

## 🧪 Paso 07: Destroy-time provisioner
```hcl
provisioner "local-exec" {
  when    = destroy
  command = "echo 'Destroy-time provisioner'"
}
```
⚠️ Si lo agregas **en este recurso**, falla:
```text
Error: Invalid reference from destroy provisioner
Destroy-time provisioners and their connection configurations may only
reference attributes of the related resource, via 'self', 'count.index', or 'each.key'.
```
El bloque `connection` compartido usa `tls_private_key...`, y en un destroy solo se puede referenciar `self`. Mira el ejemplo que funciona en [08-03](../08-03-local-exec-provisioner/).

Limpieza: `terraform destroy -auto-approve`.

📚 [file provisioner](https://developer.hashicorp.com/terraform/language/resources/provisioners/file) · Siguiente → [08-02 remote-exec](../08-02-remote-exec-provisioner/)
