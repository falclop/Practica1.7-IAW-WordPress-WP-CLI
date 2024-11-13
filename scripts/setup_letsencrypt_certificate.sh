#!/bin/bash
# mostrar los comandos que se van ejecutando

# Iniciar la variable
source .env

# la e es para parar la ejecución si falla, la x para mostrar el comando
set -ex

# Actualizamos Snap
snap install core
snap refresh core

# Borramos la instalación con apt para crearlo con snap
apt remove certbot -y

# Instalamos certbot con snap
snap install --classic certbot

# Creamos un alias para el comando certbot
ln -fs snap/bin/certbot /usr/bin/certbot

# Obtenemos el certificado con Certbot automatizado
certbot --apache -m $EMAIL_CERTBOT --agree-tos --no-eff-email -d $URL --non-interactive

# Si acaso tenemos otro certificado podemos usar este comando para instalar en nuevo certificado de Lets Encrypt
certbot install --cert-name $URL