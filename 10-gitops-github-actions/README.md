# 10 · GitOps para infraestructura (HCP Terraform ⇄ GitHub Actions)

> **En una frase:** el repositorio es la **fuente de verdad**. Cada Pull Request genera un `plan` para revisar, y cada merge a `main` aplica los cambios con una aprobación. Nadie corre `terraform apply` desde su laptop.

## 🧠 Lo esencial: el flujo
```text
  rama feature ──► Pull Request ──► 🤖 plan automático ──► 👀 review ──► merge a main ──► ⏸️ aprobar ──► 🤖 apply
                                   (comentado en el PR)                                (Confirm & Apply)
```

## ⚖️ HCP Terraform vs. este lab
El lab original usa **HCP Terraform** (ex Terraform Cloud). Ahí los planes corren en la nube de HashiCorp y **necesitan credenciales AWS reales**, y desde la nube no se llega a un moto local. Por eso armamos **el mismo flujo con GitHub Actions**:

| Concepto | HCP Terraform (lab original) | Este repo |
|---|---|---|
| Conexión con el repo (VCS) | Workspace → *Version Control Workflow* | `.github/workflows/10-gitops.yml` |
| Plan especulativo en cada PR | Automático | Job **Plan** + comentario en el PR |
| *Confirm & Apply* | Botón en la UI | **Environment `lab-moto`** con *required reviewers* |
| Variables de Terraform | Workspace → Variables | `env: TF_VAR_aws_region`, `TF_VAR_instance_type` |
| Credenciales AWS (sensitive) | Environment variables | `secrets.AWS_*` (acá: `testing`, porque es moto) |
| State remoto + locking | Incluido | Backend S3 (sección 06). En CI, moto arranca vacío en cada run |
| Un run a la vez | Run queue | `concurrency: terraform-10-gitops` |
| *Queue destroy plan* | Settings → Destruction | *Actions → Run workflow → destroy* |
| Historial de runs | Runs | Pestaña **Actions** |

🧪 **Truco del job Plan:** moto empieza vacío en cada run. Para que el plan del PR muestre el **diff real** (y no "crear todo"), primero aplica la versión de `main` y después planifica la de tu rama. Así se simula la infraestructura que ya existe.

## ▶️ Probarlo (Paso 13 del lab: "Change Number of Instances")
```bash
git checkout -b feature/ec2-count-2
# c4-ec2-instance.tf: count = 1  ->  count = 2
git commit -am "Changed EC2 Instances from 1 to 2"
git push -u origin feature/ec2-count-2
gh pr create --fill
```
1. En el PR aparece el comentario del bot con el plan: **`Plan: 1 to add, 0 to change, 0 to destroy`**.
2. Merge → en *Actions* el job **Apply** queda en ⏸️ *Waiting*. Haz clic en **Review deployments → Approve** (= *Confirm & Apply*).
3. En el *Summary* del run se ven los outputs: `ec2_names = ["Terraform-Cloud-0", "Terraform-Cloud-1"]`.

## ▶️ Local (igual que el paso 05 del lab: "verificar antes del push")
```bash
cd terraform-manifests
export TF_VAR_aws_region=us-east-1 TF_VAR_instance_type=t3.micro   # PowerShell: $env:TF_VAR_aws_region="us-east-1"
terraform init && terraform validate && terraform plan
```

## ☁️ Si algún día usas HCP Terraform real (resumen del lab original)
1. Crea una cuenta en `app.terraform.io` → crea una **Organization** → **New Workspace → Version Control Workflow → GitHub** → elige este repo y, en *Advanced*, pon **Terraform Working Directory** = `10-gitops-github-actions/terraform-manifests`.
2. **Variables**: `aws_region`, `instance_type` (Terraform) + `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` (Environment, ✅ *Sensitive*).
3. Borra `moto_override.tf`. **Queue plan → Confirm & Apply**. Cada `git push` dispara un nuevo run.
4. Al terminar: **Settings → Destruction and Deletion → Queue destroy plan**.

## 💡 Para recordar
- GitOps = **PR como puerta de entrada** para cambiar la infraestructura: revisión, historial y rollback (`git revert`).
- 🔐 En AWS real, prefiere **OIDC** (`aws-actions/configure-aws-credentials` con un rol IAM) a guardar access keys como secrets.
- 🔄 **Cambio vs. el lab original:** se quitó `key_name = "terraform-key"`, porque este lab no usa SSH.

📚 [HCP Terraform VCS workflow](https://developer.hashicorp.com/terraform/cloud-docs/run/ui) · [Automate Terraform with GitHub Actions](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions)
