# 08-02 · remote-exec Provisioner

> **En una frase:** `remote-exec` corre comandos **dentro** del servidor por SSH. Combinado con `file`, primero copias y después instalas o mueves.

## 🧠 Lo esencial
```hcl
provisioner "file" {                       # 1) copiar a /tmp (ec2-user sí puede escribir ahí)
  source      = "apps/file-copy.html"
  destination = "/tmp/file-copy.html"
}

provisioner "remote-exec" {                # 2) moverlo con sudo a la carpeta de Apache
  inline = [
    "while [ ! -d /var/www/html ]; do sleep 1; done",   # esperar al user_data
    "sudo cp /tmp/file-copy.html /var/www/html",
  ]
}
```
- `inline` = lista de comandos. También existen `script = "x.sh"` y `scripts = [...]`.
- Los provisioners corren **en el orden en que están escritos**.
- ⏱️ El lab original usa `sleep 120` para esperar que `user_data` instale Apache. Esperar a una **condición** (que exista el directorio) es más rápido y más confiable que un tiempo fijo.

## ▶️ Ejecutar (sin AWS, con Docker)
```bash
terraform init && terraform apply -auto-approve
curl http://localhost:8080/file-copy.html
terraform destroy -auto-approve
```

## 👀 Salida real
```text
docker_container.my-ec2-vm: Provisioning with 'file'...
docker_container.my-ec2-vm: Provisioning with 'remote-exec'...
docker_container.my-ec2-vm (remote-exec): Connecting to remote host via SSH...
docker_container.my-ec2-vm (remote-exec):   Host: 127.0.0.1
docker_container.my-ec2-vm (remote-exec):   User: ec2-user
docker_container.my-ec2-vm (remote-exec):   Private key: true
docker_container.my-ec2-vm (remote-exec): Connected!
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
file_url = "http://localhost:8080/file-copy.html"

$ curl http://localhost:8080/file-copy.html
<h1>Simple file copy using Terraform File Provisioner</h1>
```

## 💡 Para recordar
- El servidor necesita el **puerto 22** abierto desde donde corre Terraform (en AWS: regla del security group `vpc-ssh`).
- Si un comando devuelve un código distinto de 0, el provisioner falla y el recurso queda **tainted**.

📚 [remote-exec](https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec) · Siguiente → [08-03 local-exec](../08-03-local-exec-provisioner/)
