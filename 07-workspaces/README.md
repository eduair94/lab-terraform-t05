# 07 · Workspaces

> **En una frase:** el mismo código con **varios states independientes** (default, dev, qa...). Cada workspace es un ambiente separado.

## 🧠 Lo esencial
```hcl
name  = "vpc-ssh-${terraform.workspace}"                 # nombres únicos por ambiente
count = terraform.workspace == "default" ? 2 : 1         # comportamiento según el ambiente
tags  = { Name = "vm-${terraform.workspace}-${count.index}" }
```
| Comando | Qué hace |
|---|---|
| `terraform workspace list` / `show` | Lista los workspaces / muestra el actual (`*`) |
| `terraform workspace new dev` | Crea `dev` y se cambia a él |
| `terraform workspace select default` | Cambia de workspace |
| `terraform workspace delete dev` | Lo borra (debe estar vacío y no ser el actual) |

**¿Dónde queda cada state?**
| | default | dev |
|---|---|---|
| v1 · local | `terraform.tfstate` | `terraform.tfstate.d/dev/terraform.tfstate` |
| v2 · S3 | `workspaces/terraform.tfstate` | `env:/dev/workspaces/terraform.tfstate` |

## ▶️ Ejecutar (sin AWS)
```bash
cd v1-local-backend                 # v2: init -backend-config=backend-moto.hcl (requiere 06-00)
terraform init
terraform apply -auto-approve       # default -> 2 VMs
terraform workspace new dev
terraform apply -auto-approve       # dev -> 1 VM
```

## 👀 Salida real (moto)
```text
# default
ec2_names = ["vm-default-0", "vm-default-1"]
workspace = "default"
# dev
ec2_names = ["vm-dev-0"]
workspace = "dev"

$ find . -name "terraform.tfstate*"
./terraform.tfstate
./terraform.tfstate.d/dev/terraform.tfstate

# v2 (S3)
$ aws s3 ls s3://terraform-devopslab-state --recursive
env:/dev/workspaces/terraform.tfstate
workspaces/terraform.tfstate
```
**Las reglas de borrado** (errores reales):
```text
$ terraform workspace delete dev                  # con recursos adentro
Error: Workspace is not empty
Workspace "dev" is currently tracking the following resource instances:
  - aws_security_group.vpc-ssh ...

$ terraform workspace delete dev                  # estando parado en dev
Workspace "dev" is your active workspace.
You cannot delete the currently active workspace.

$ terraform workspace delete default
Cannot delete the default workspace
```
Orden correcto: `select dev` → `destroy` → `select default` → `workspace delete dev` → `destroy`.

## 💡 Para recordar
- `${terraform.workspace}` evita choques de nombres (dos SG con el mismo nombre en la misma VPC dan error en AWS).
- ⚖️ Workspaces vs. carpetas por ambiente: con workspaces es fácil hacer `apply` en el ambiente equivocado. Muchos equipos prefieren `envs/dev`, `envs/prod` con backends separados. Haz siempre `terraform workspace show` antes de un `apply`.
- 🔄 **Cambio vs. el lab original:** `aws_instance.x.*.ip` (splat viejo) → `aws_instance.x[*].ip`.

📚 [Workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) · Siguiente → [08 Provisioners](../08-provisioners/)
