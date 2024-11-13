#!/bin/bash
#mostrar los comandos que se van ejecutando
#la e es para parar la ejecución si falla, la x para mostrar el comando
#Le llamamos LAMP: Linux, Apache, MySql, PHP
set -ex

#Actualizar el repositorio
apt update

#Actualiza el paquete
apt upgrade -y

#Instalar apache 2
apt install apache2 -y

#Habilitamos modulos rewrite
a2enmod rewrite

#Copiamos el archivo de configuración de Apache, tendremos que ejecutar el scripts desde el directorio script
cp ../conf/000-default.conf /etc/apache2/sites-available

#Instalación de PHP y los módulos de conexión con Apache
apt install php libapache2-mod-php php-mysql -y

#Reinicio de apache2
systemctl restart apache2

#Instalar MySQL_server
sudo apt install mysql-server -y

#Copia de nuestro archivo php a directorio web
cp ../php/index.php /var/www/html

#Modificar el propietario del directorio y el interior de var www html
chown -R www-data:www-data /var/www/html