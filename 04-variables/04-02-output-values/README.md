# 04-02 · Output Values

> **En una frase:** los outputs son el **valor de retorno** de tu configuración. Muestran datos que AWS calcula al crear un recurso (IP, DNS, ARN) para que los use una persona, un script o un módulo padre.

## 🧠 Lo esencial
```hcl
output "ec2_publicdns" {
  description = "Public DNS URL of an EC2 Instance"
  value       = "http://${aws_instance.my-ec2-vm.public_dns}"   # interpolación
  sensitive   = true                                            # opcional
}
```
- **Argument reference**: un valor que tú escribiste (`vpc_security_group_ids`).
- **Attribute reference**: un valor que AWS genera (`public_ip`, `arn`). En el plan aparece como `(known after apply)`.

## ▶️ Ejecutar (sin AWS)
```bash
terraform init && terraform apply -auto-approve
terraform output                        # todos
terraform output ec2_publicdns          # uno (entre comillas)
terraform output -raw ec2_instance_publicip   # sin comillas: ideal para scripts
terraform output -json                  # para jq / pipelines
```

## 👀 Salida real (moto)
```text
Outputs:
ec2_instance_privateip = "10.32.54.193"
ec2_instance_publicip  = "54.214.169.253"
ec2_publicdns          = "http://ec2-54-214-169-253.compute-1.amazonaws.com"
ec2_security_groups    = toset(["sg-db498f6bb3984194f", "sg-ffb8b7791eba5d5af"])

$ terraform output -raw ec2_instance_publicip
54.214.169.253
```
**Paso 4.** Descomenta `sensitive = true` en `c5-outputs.tf` y ejecuta `apply`:
```text
ec2_publicdns = <sensitive>                                   <- oculto en apply y en "terraform output"

$ terraform output ec2_publicdns                              <- pero si lo pides por nombre...
"http://ec2-54-214-169-253.compute-1.amazonaws.com"           <- ...se muestra (lo lee del state)

$ terraform output -json
"ec2_publicdns": { "sensitive": true, "type": "string", "value": "http://ec2-54-..." }
```

## 💡 Para recordar
- `sensitive` evita que el valor quede en logs. **No lo cifra**: sigue en el state.
- Un caso típico de CI/CD: `IP=$(terraform output -raw ec2_instance_publicip)` y luego `curl http://$IP`.
- En los módulos (sección 09), los outputs son la forma de pasarle datos al módulo padre.
- 🔄 **Cambio vs. el lab original:** `security_groups` → `vpc_security_group_ids` (el primero es solo para EC2-Classic o la VPC default).

📚 [Outputs](https://developer.hashicorp.com/terraform/language/values/outputs) · Siguiente → [04-03 Locals](../04-03-local-values/)
