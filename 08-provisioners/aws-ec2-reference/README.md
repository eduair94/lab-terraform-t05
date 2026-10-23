# 08 · Referencia: provisioners sobre una EC2 real

Esta es la versión **AWS** de 08-01 y 08-02 (la que corre el lab original). No se puede ejecutar con moto, porque sus instancias no tienen SSH. Solo se valida:
```bash
terraform init -backend=false && terraform validate
```
Diferencias con la versión Docker:
- `host = self.public_ip` en vez de `127.0.0.1:2222`.
- `sleep 120` para esperar el `user_data`.
- **Mejora vs. el lab original:** la clave SSH la genera Terraform (`tls_private_key` + `aws_key_pair`) en vez de descargar un `.pem` y subirlo al repositorio. El repo del curso tiene `private-key/terraform-key.pem` versionado: es una práctica a evitar.

Con créditos AWS: `aws configure`, después `terraform init && terraform apply`, y al terminar `terraform destroy`.
