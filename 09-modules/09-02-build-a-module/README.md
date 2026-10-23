# 09-02 · Construir un módulo propio (sitio estático en S3)

> **En una frase:** primero lo haces **a mano**, después lo **automatizas** con recursos y al final lo **empaquetas** en un módulo reutilizable.

## 🧠 La progresión

| Carpeta | Cómo | Qué aprendes |
|---|---|---|
| [v1-manual-aws-cli](v1-manual-aws-cli/) | 5 comandos de AWS CLI (= los clics de la consola) | Qué hace falta para un sitio estático |
| [v2-terraform-resources](v2-terraform-resources/) | 4 recursos de Terraform | Automatizar |
| [v3-module](v3-module/) | `module "website_s3_bucket" { source = "./modules/..." }` | Reutilizar: otro sitio = 4 líneas |

**Los 4 ingredientes** (las 4 piezas del módulo):
1. `aws_s3_bucket`: el bucket
2. `aws_s3_bucket_website_configuration`: hosting con `index.html`
3. `aws_s3_bucket_public_access_block`: quitar el "Block all public access"
4. `aws_s3_bucket_policy`: lectura pública (`s3:GetObject` para `*`)

**Estructura de un módulo:**
```text
v3-module/                         <- root module
├── c3-s3bucket.tf                 <- module "website_s3_bucket" { source = "./modules/aws-s3-static-website-bucket" }
└── modules/aws-s3-static-website-bucket/
    ├── main.tf        (recursos)
    ├── variables.tf   (inputs: bucket_name, tags)
    ├── outputs.tf     (outputs: arn, name, domain, endpoint)
    └── README.md      (documentación del "contrato")
```

## ▶️ Ejecutar (sin AWS)
```bash
# v1: a mano
cd v1-manual-aws-cli && bash manual-steps.sh

# v2 / v3: con Terraform
cd ../v3-module
terraform init && terraform apply -auto-approve
aws --endpoint-url http://localhost:5000 s3 cp index.html s3://mybucket-1047/index.html
curl http://localhost:5000/mybucket-1047/index.html
terraform destroy -auto-approve
```

## 👀 Salida real (moto)
```text
# v1
   <h1>Welcome to practico de Terraform -  Terraform Modules Demo</h1>
OK - 5 pasos manuales.

# v3: init
Initializing modules...
- website_s3_bucket in modules\aws-s3-static-website-bucket
- website_s3_bucket_qa in modules\aws-s3-static-website-bucket

Apply complete! Resources: 8 added, 0 changed, 0 destroyed.     <- 2 sitios x 4 recursos
website_bucket_endpoint = "mybucket-1047.s3-website-us-east-1.amazonaws.com"
website_bucket_qa_name  = "mybucket-1047-qa"

$ terraform state list
module.website_s3_bucket.aws_s3_bucket.s3_bucket
module.website_s3_bucket.aws_s3_bucket_policy.s3_bucket
...
module.website_s3_bucket_qa.aws_s3_bucket_website_configuration.s3_bucket
```
⭐ **Extra:** `website_s3_bucket_qa` llama **al mismo módulo** con otros parámetros. Esa es la idea de un módulo.

### Local vs. remoto (comprobado)
```text
$ cat .terraform/modules/modules.json
{"Key":"website_s3_bucket","Source":"./modules/aws-s3-static-website-bucket","Dir":"modules/aws-s3-static-website-bucket"}
```
- Un módulo **local** **no se copia**: Terraform usa la carpeta original, así que ve tus cambios sin volver a hacer `init`. Solo hace falta `init`/`get` si **agregas** un bloque `module` nuevo.
- Un módulo **remoto** (Registry, Git) **se descarga** a `.terraform/modules/<nombre>/`. Para actualizarlo: `terraform get -update` o `terraform init -upgrade`.

## 💡 Para recordar
- Un buen módulo expone **solo lo que cambia** entre usos (nombre, tags) y trae defaults razonables para lo demás.
- 🔄 **Cambios vs. el lab original:** el bloque único `aws_s3_bucket { acl, policy, website }` (AWS v3) ya no existe en AWS v4+: ahora son 4 recursos. La policy se arma con `jsonencode()` en vez de un heredoc JSON, y lleva `depends_on` al public access block (sin eso AWS la rechaza).

📚 [Creating modules](https://developer.hashicorp.com/terraform/language/modules/develop) · Siguiente → [10 GitOps](../../10-gitops-github-actions/)
