# 08 · Provisioners

> **En una frase:** los provisioners ejecutan acciones **después** de crear (o antes de destruir) un recurso: copiar archivos, correr comandos por SSH o correr comandos en tu propia máquina. Son el **último recurso**.

## 🧠 Lo esencial

| Provisioner | Dónde corre | Necesita SSH | Lab |
|---|---|:-:|---|
| `file` | Copia **de tu PC → servidor** | ✅ | [08-01](08-01-file-provisioner/) |
| `remote-exec` | Comandos **en el servidor** | ✅ | [08-02](08-02-remote-exec-provisioner/) |
| `local-exec` | Comandos **en tu PC** (o en el runner de CI) | ❌ | [08-03](08-03-local-exec-provisioner/) |
| `null_resource` / `terraform_data` | Provisioners "sueltos", con triggers | según el caso | [08-04](08-04-null-resource/) |

**Cuándo se ejecutan**
- **Creation-time** (por defecto): una sola vez, al **crear**. No se ejecutan en los updates.
- **Destroy-time** (`when = destroy`): antes de destruir el recurso.

**Si fallan** (`on_failure`)
- `fail` (por defecto): el `apply` se corta y el recurso queda **tainted**. En el próximo `apply` se destruye y se vuelve a crear.
- `continue`: ignora el error y sigue.

**¿Por qué "último recurso"?** Terraform no sabe qué hizo tu script: no puede planificarlo, ni repetirlo de forma segura, ni detectar drift. Antes prueba con `user_data`/cloud-init, una AMI ya preparada (Packer) o Ansible.

## 🐳 ¿Cómo se practica sin AWS?
Moto simula la **API** de AWS, pero sus EC2 no existen: no tienen SSH. Por eso, en 08-01, 08-02 y 08-04 la "EC2" es un **contenedor Docker con OpenSSH**:

| EC2 en AWS | Acá |
|---|---|
| `aws_instance` | `docker_container` (imagen `linuxserver/openssh-server`) |
| `user_data = file("apache-install.sh")` | bloque `upload` que copia el script a `/custom-cont-init.d/` |
| Apache en el puerto 80 | `httpd` de busybox → `http://localhost:8080` |
| Key pair `terraform-key.pem` | `tls_private_key` (Terraform la genera; nada que subir a git) |
| `host = self.public_ip` | `host = "127.0.0.1"`, `port = 2222` |

Los provisioners (`connection`, `file`, `remote-exec`, `self`, `on_failure`, tainted) funcionan **igual** en los dos casos. La versión EC2 real (validada con `terraform validate`) está en [aws-ec2-reference/](aws-ec2-reference/).

**Requisito:** Docker Desktop corriendo. Los providers `docker`, `tls`, `local`, `null` y `time` se descargan solos con `terraform init`.
