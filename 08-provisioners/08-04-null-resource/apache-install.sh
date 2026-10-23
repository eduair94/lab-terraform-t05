#!/bin/sh
# Equivalente al user_data de la EC2: corre UNA vez como root al arrancar el "servidor".
apk add --no-cache busybox-extras >/dev/null   # trae un httpd minimo (nuestro "Apache")
mkdir -p /var/www/html
echo "<h1>Welcome to Practico Terraform ! (fake EC2 en Docker)</h1>" > /var/www/html/index.html
httpd -p 80 -h /var/www/html
