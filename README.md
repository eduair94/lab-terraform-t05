# 🏗️ Lab Terraform: T05 Infrastructure as Code (secciones 03 → 10)

Resolución del [laboratorio T05 de ORT-ATI DevOps](https://ort-ati-certificadodevops.github.io/Laboratorios/#/T05%20-%20Infrastructure%20as%20Code/index) **sin cuenta de AWS y sin gastar créditos**. Cada lab tiene el código modernizado, cómo ejecutarlo, la **salida real** de la ejecución y lo más importante para recordar.

[![CI](https://github.com/eduair94/lab-terraform-t05/actions/workflows/ci.yml/badge.svg)](https://github.com/eduair94/lab-terraform-t05/actions/workflows/ci.yml)

## 🧪 ¿Cómo funciona sin AWS?

| Necesidad | Solución | Cómo |
|---|---|---|
| API de AWS (EC2, VPC, S3, IAM, RDS, DynamoDB) | **[moto](https://github.com/getmoto/moto)**: AWS simulado en `localhost:5000` | Cada lab trae un `moto_override.tf` |
| Servidor con SSH para los provisioners | **Docker**: un contenedor con OpenSSH hace de "EC2" | Ver [08-provisioners](08-provisioners/) |
| HCP Terraform (Terraform Cloud) | **GitHub Actions** con el mismo flujo GitOps | Ver [10-gitops](10-gitops-github-actions/) |

> **`*_override.tf`**: Terraform mezcla automáticamente estos archivos con el resto del código. El nuestro redirige el provider AWS a moto. **Para usar AWS real, borra `moto_override.tf`** (y en los labs con backend S3, ejecuta `terraform init` sin `-backend-config`).

## 🚀 Setup (una vez)
```bash
# 1) Terraform >= 1.6     Windows: winget install Hashicorp.Terraform   macOS: brew install terraform
# 2) AWS CLI (opcional, para "tocar la consola")   pip install awscli   o AWS CLI v2
# 3) Levantar moto
bash scripts/moto.sh start            # con Docker. Sin Docker: pip install "moto[server]" && moto_server -p 5000
# 4) Credenciales falsas para la AWS CLI
export AWS_ACCESS_KEY_ID=testing AWS_SECRET_ACCESS_KEY=testing AWS_DEFAULT_REGION=us-east-1
alias awsl='aws --endpoint-url http://localhost:5000'
```
PowerShell: `$env:AWS_ACCESS_KEY_ID="testing"; $env:AWS_SECRET_ACCESS_KEY="testing"; $env:AWS_DEFAULT_REGION="us-east-1"`

Después, en cualquier lab: `terraform init` → `terraform plan` → `terraform apply -auto-approve` → `terraform destroy -auto-approve`.
`bash scripts/moto.sh reset` deja moto como una cuenta recién creada.

## 🧠 El modelo mental (todo el lab en 4 líneas)
```text
  *.tf (DESIRED state)  ──┐
                          ├──► terraform plan  ──► diff: + create  ~ update  -/+ replace  - destroy
  terraform.tfstate  ─────┘        (CURRENT state = lo que Terraform cree que existe)
                                   terraform apply ──► llama a la API (AWS/moto) y actualiza el state
```

## 📚 Índice

| # | Lab | Concepto clave en una línea |
|---|---|---|
| 03-01 | [Resource behavior](03-resources/03-01-resource-behavior/) | create / update in-place / replace / destroy |
| 03-02 | [depends_on](03-resources/03-02-depends-on/) | Dependencias implícitas (referencias) vs. explícitas |
| 03-03 | [count](03-resources/03-03-count/) | N copias, identificadas por posición `[0]` |
| 03-04 | [for_each](03-resources/03-04-for-each/) | N copias, identificadas por clave `["dev"]`. ⭐ experimento count vs for_each |
| 03-05 | [lifecycle](03-resources/03-05-lifecycle/) | `create_before_destroy`, `prevent_destroy`, `ignore_changes` |
| 04-01 | [Input variables](04-variables/04-01-input-variables/) | Precedencia (probada), tipos, validación, `sensitive` |
| 04-02 | [Outputs](04-variables/04-02-output-values/) | `terraform output`, `-raw`, `-json`, `sensitive` |
| 04-03 | [Locals](04-variables/04-03-local-values/) | DRY: `local.x` + `merge()` |
| 05 | [Data sources](05-datasources/) | Leer sin crear: AMI de Amazon Linux 2023 |
| 06-00 | [Backend bootstrap](06-state/06-00-backend-bootstrap/) | Crear bucket + tabla de lock **con Terraform** |
| 06-01 | [Remote state + locking](06-state/06-01-remote-state-locking/) | S3 + versionado + DynamoDB / `use_lockfile` |
| 06-02 | [State commands](06-state/06-02-state-commands/) | refresh-only, mv/`moved`, rm/`import`, force-unlock, -replace, -target |
| 07 | [Workspaces](07-workspaces/) | Un código, varios states (`default`, `dev`) |
| 08 | [Provisioners](08-provisioners/) | file, remote-exec, local-exec, null_resource / terraform_data |
| 09-01 | [Modules basics](09-modules/09-01-module-basics/) | Módulo del Registry + `for_each` en el módulo |
| 09-02 | [Build a module](09-modules/09-02-build-a-module/) | Manual → recursos → módulo reutilizable |
| 10 | [GitOps](10-gitops-github-actions/) | Plan en el PR, apply con aprobación (= HCP Terraform) |

## ⚡ Chuleta de comandos
```bash
terraform init [-upgrade] [-backend-config=f.hcl] [-reconfigure]
terraform fmt -recursive && terraform validate
terraform plan [-out=p.out] [-var k=v] [-var-file=f.tfvars] [-target=addr] [-replace=addr]
terraform apply [p.out] [-auto-approve] [-refresh-only]
terraform destroy [-auto-approve]
terraform output [-raw|-json] [name]
terraform console                          # probar expresiones: length(), substr(), var.x
terraform state list|show|mv|rm|pull|push
terraform workspace list|show|new|select|delete
terraform force-unlock <LOCK_ID>
terraform graph                            # grafo de dependencias (DOT)
```

## 🔄 Cambios respecto al código del curso (y por qué)
El código original apunta a Terraform 0.14 y al provider AWS 3.x, y **no corre** con versiones actuales:

| Original | Acá | Por qué |
|---|---|---|
| `required_version = "~> 0.14"`, `aws ~> 3.0` | `>= 1.6`, `aws ~> 5.0` | Versiones vigentes (igual que el README del curso) |
| `profile = "default"` | sin `profile` | Las credenciales se toman del entorno (o de moto) |
| `aws_eip { vpc = true }` | `domain = "vpc"` | Removido en AWS v5 |
| `aws_s3_bucket { acl, policy, website }` | Recursos separados | Cambio de AWS v4 |
| `aws_db_instance { name, db.t2.micro }` | `db_name`, `db.t3.micro` | Removido / ya no existe |
| Amazon Linux 2 + `yum` | Amazon Linux 2023 + `dnf` | AL2 sin soporte desde 2025 |
| `terraform taint` | `terraform apply -replace` | `taint` está deprecado |
| `.pem` versionado en git | `tls_private_key` | Nunca subas claves a un repo |
| IDs hardcodeados (`sg-...`, `subnet-...`) | data sources | Los IDs de otra cuenta no sirven |
| `self` faltante en `local-exec` | `${self.private_ip}` | Un recurso no puede referenciarse por su nombre |

## 🧹 Limpieza
`terraform destroy -auto-approve` en cada lab (en 06-00, al final) → `bash scripts/moto.sh stop`.
`bash scripts/test-all.sh apply` ejecuta **todos** los labs de punta a punta (es lo que corre el CI).

---
Material base: [ORT-ATI-CertificadoDevOps/Laboratorios](https://github.com/ORT-ATI-CertificadoDevOps/Laboratorios)
