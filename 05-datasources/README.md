# 05 · Data Sources

> **En una frase:** un `data` **lee** algo que ya existe en el proveedor (un AMI, una VPC, una zona) sin crearlo ni administrarlo.

## 🧠 Lo esencial

| | `resource` | `data` |
|---|---|---|
| Acción | Crea, modifica y destruye | **Solo lee** |
| Referencia | `aws_instance.x.id` | `data.aws_ami.x.id` |
| Ejemplo | Crear una EC2 | "Dame el AMI más nuevo de Amazon Linux 2023" |

```hcl
data "aws_ami" "amzlinux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]     # comodín *
  }
  # + filtros root-device-type, virtualization-type, architecture
}

resource "aws_instance" "my-ec2-vm" {
  ami = data.aws_ami.amzlinux.id    # ya no hay IDs hardcodeados
}
```
**¿Por qué?** Los IDs de AMI cambian con cada versión y son distintos en cada región. Un AMI hardcodeado queda viejo (o deja de existir). El data source busca el correcto en cada `plan`.

## ▶️ Ejecutar (sin AWS)
```bash
terraform init
terraform plan                      # fíjate en "Reading..." ANTES de planificar
terraform apply -auto-approve
echo 'data.aws_ami.amzlinux.name' | terraform console
terraform destroy -auto-approve
```

## 👀 Salida real (moto)
```text
data.aws_ami.amzlinux: Reading...
data.aws_ami.amzlinux: Read complete after 0s [id=ami-03c3da4cfa8e8943a]
      + ami = "ami-03c3da4cfa8e8943a"        <- ya se conoce en el PLAN (no "known after apply")

Outputs:
ami_id   = "ami-03c3da4cfa8e8943a"
ami_name = "al2023-ami-2023.12.20260930.0-kernel-6.1-x86_64"
ec2_instance_publicip = "54.214.9.93"
```

## 💡 Para recordar
- Cómo armar los filtros: en la consola de AWS, ve a **EC2 → AMIs → Public images**, busca la imagen y copia el patrón del *AMI name* y el *Owner*.
- Otros data sources muy usados: `aws_vpc` (default = true), `aws_subnets`, `aws_availability_zones`, `aws_caller_identity`.
- ⚠️ `most_recent = true` puede cambiar el AMI cuando sale una versión nueva y forzar el **reemplazo** de la instancia. En producción se fija la versión o se usa `lifecycle { ignore_changes = [ami] }`.
- 🔄 **Cambio vs. el lab original:** filtro `amzn2-ami-hvm-*` (Amazon Linux 2, sin soporte) → `al2023-ami-2023*` y `yum` → `dnf` en `apache-install.sh`.

📚 [aws_ami data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) · Siguiente → [06-01 Remote State](../06-state/06-01-remote-state-locking/)
