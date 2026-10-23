# 09-01 · Módulos: lo básico (Terraform Registry)

> **En una frase:** un módulo es una **carpeta de `.tf` reutilizable**, que funciona como una función: recibe *inputs* (variables) y devuelve *outputs*.

## 🧠 Lo esencial
| Término | Qué es |
|---|---|
| **Root module** | La carpeta donde ejecutas `terraform` |
| **Child module** | Cualquier módulo que llamas con `module "x" {}` |
| **Published module** | Un módulo del [Terraform Registry](https://registry.terraform.io/), de Git, de S3... |

```hcl
module "ec2_cluster" {
  source  = "terraform-aws-modules/ec2-instance/aws"   # <namespace>/<nombre>/<provider>
  version = "~> 5.0"                                   # fíjala siempre
  for_each = toset(["one", "two"])                     # meta-arguments: count, for_each, depends_on, providers

  name          = "my-modules-demo-${each.key}"        # inputs = variables del módulo
  ami           = data.aws_ami.amzlinux.id
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnets.default.ids[0]
  ...
}

output "ec2_instance_public_ip" {
  value = { for k, m in module.ec2_cluster : k => m.public_ip }   # module.<nombre>.<output>
}
```

## ▶️ Ejecutar (sin AWS)
```bash
terraform init            # descarga el módulo a .terraform/modules/
terraform apply -auto-approve
terraform state list
terraform destroy -auto-approve
```

## 👀 Salida real (moto)
```text
Downloading registry.terraform.io/terraform-aws-modules/ec2-instance/aws 5.8.0 for ec2_cluster...

module.ec2_cluster["one"].aws_instance.this[0]: Creation complete after 12s
module.ec2_cluster["two"].aws_instance.this[0]: Creation complete after 12s
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

ec2_instance_public_ip = {
  "one" = "54.214.195.51"
  "two" = "54.214.202.178"
}

$ terraform state list
module.ec2_cluster["one"].aws_instance.this[0]      <- dirección: module.<nombre>[clave].<recurso>
module.ec2_cluster["two"].aws_instance.this[0]
```
**Recrear un recurso de un módulo** (`taint` está deprecado):
```text
$ terraform plan -replace='module.ec2_cluster["one"].aws_instance.this[0]'
  # module.ec2_cluster["one"].aws_instance.this[0] will be replaced, as requested
```
No se puede reemplazar un **módulo entero**: se indica cada recurso por separado.

## 💡 Para recordar
- Lee la pestaña **Inputs/Outputs** del módulo en el Registry. Es su "contrato".
- 🔄 **Cambios vs. el lab original:**
  - Módulo `~> 2.0` (con `instance_count`) → `~> 5.0` + `for_each` **sobre el módulo**.
  - Los IDs hardcodeados `sg-08b2...` y `subnet-4ee9...` (de la cuenta del profe) → data sources `aws_vpc`, `aws_subnets` y `aws_security_group` de la VPC default.
  - `module.ec2_cluster.*.public_ip` → `for` expression sobre el map de módulos.
- 🧪 **Limitaciones de moto:** no implementa `MonitorInstances`, por eso `monitoring` es una variable (`-var=detailed_monitoring=true` en AWS real). Además, el `plan` puede mostrar `+ enclave_options {}` después del apply: es un detalle de moto que no pasa en AWS.

📚 [Modules](https://developer.hashicorp.com/terraform/language/modules) · Siguiente → [09-02 Build a Module](../09-02-build-a-module/)
