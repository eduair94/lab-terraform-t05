# 08-03 · local-exec Provisioner (+ destroy-time)

> **En una frase:** `local-exec` corre un comando **en tu máquina** (o en el runner de CI) cuando se crea o se destruye un recurso. No necesita SSH.

## 🧠 Lo esencial
```hcl
provisioner "local-exec" {                 # creation-time
  command     = "echo ${self.private_ip} >> creation-time-private-ip.txt"
  working_dir = "local-exec-output-files/"
}

provisioner "local-exec" {                 # destroy-time
  when        = destroy
  command     = "echo Destroy-time provisioner Instance Destroyed at ${timestamp()} >> destroy-time.txt"
  working_dir = "local-exec-output-files/"
}
```
Usos típicos: avisar a Slack, generar un inventario para Ansible, registrar en una CMDB o llamar a un script de integración.

## ▶️ Ejecutar (sin AWS, con moto)
```bash
terraform init && terraform apply -auto-approve
cat local-exec-output-files/creation-time-private-ip.txt
terraform destroy -auto-approve
cat local-exec-output-files/destroy-time.txt
```

## 👀 Salida real (moto, Windows)
```text
aws_instance.my-ec2-vm: Provisioning with 'local-exec'...
aws_instance.my-ec2-vm (local-exec): Executing: ["cmd" "/C" "echo 10.186.60.189 >> creation-time-private-ip.txt"]
private_ip = "10.186.60.189"

# terraform destroy
aws_instance.my-ec2-vm (local-exec): Executing: ["cmd" "/C" "echo Destroy-time provisioner Instance Destroyed at 2026-10-23T02:03:17Z >> destroy-time.txt"]
Destroy complete! Resources: 3 destroyed.
```
Fíjate en `["cmd" "/C" ...]`: en Windows Terraform usa `cmd`, y en Linux/macOS usa `/bin/sh -c`. Para elegir otro intérprete: `interpreter = ["bash", "-c"]`.

## 💡 Para recordar
- 🔄 **Cambios vs. el lab original** (el original no funciona en Terraform moderno):
  - `${aws_instance.my-ec2-vm.private_ip}` dentro del propio recurso → `${self.private_ip}`. Un recurso no puede referenciarse por su nombre (sería un ciclo).
  - `` `date` `` (solo funciona en bash) → `${timestamp()}` (función de Terraform: funciona en cualquier sistema operativo).
  - Se quitó `key_name`: `local-exec` no usa SSH.
- Un destroy-time provisioner solo puede usar `self`, `count.index` y `each.key`.
- Si borras el bloque `resource` completo, sus destroy-time provisioners **no** se ejecutan (Terraform ya no tiene la configuración).

📚 [local-exec](https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec) · Siguiente → [08-04 null_resource](../08-04-null-resource/)
