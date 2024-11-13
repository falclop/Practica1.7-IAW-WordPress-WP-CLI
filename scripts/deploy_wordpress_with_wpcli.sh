#!/bin/bash

#Iniciar la variable
source .env

#la e es para parar la ejecución si falla, la x para mostrar el comando
set -ex

# eliminamos instalaciones anteriores
rm -rf /opt/*

# Descargamos el código fuente de wp cli (man es manual / export para ver variables de entorno de la sesión)
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp

# Damos permisos de ejecución al archivo
chmod +x /tmp/wp-cli.phar

# movemos el script a usr/local/bin/
mv /tmp/wp-cli.phar /usr/local/bin/wp

# eliminamos instalaciones anteriores
rm -rf /var/www/html/*

# Instalamos worpress con el cli y las opciones wp core
wp core download --locale=es_ES --path=$WP_PATH --allow-root

# Creamos la base de datos de wordpress
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

# Creamos el archivo de configuración
wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --dbhost=$IP_CLIENTE_MYSQL \
  --path=$WP_PATH \
  --allow-root

# Creamos el sitio de wordpress
wp core install \
  --url=$URL \
  --title=$WP_TITLE \
  --admin_user=$WP_USER \
  --admin_password=$WP_PASS \
  --admin_email=$WP_EMAIL \
  --path=$WP_PATH \
  --allow-root

# Cambiamos a todo los permisos de www-data
chown -R www-data:www-data /var/www/html