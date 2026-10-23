#!/bin/bash
# user_data: se ejecuta UNA vez, como root, al primer arranque de la instancia.
dnf install -y httpd   # Amazon Linux 2023 usa dnf (AL2 usaba yum)
systemctl enable --now httpd
echo "<h1>Welcome to Practico Terraform ! AWS Infra created using Terraform</h1>" > /var/www/html/index.html
