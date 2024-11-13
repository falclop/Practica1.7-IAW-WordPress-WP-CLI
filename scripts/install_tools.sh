#!/bin/bash

#Iniciar la variable
source .env

#la e es para parar la ejecución si falla, la x para mostrar el comando
set -ex

#Actualizar el repositorio
apt update

#Actualiza el paquete
apt upgrade -y

#automatización de las selecciones del debconf
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections

#Preparacion de PHPmyAdmin con diferentes paquetes zip, gd, 
sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

#------------------------------------------------------------------------------------------------------------------------------
#1. Creación de directorio para Adminer - app de gestión php más ligera (-p si ya existe sigue ejecutando)
mkdir -p /var/www/html/adminer

#2. descargar el archivo (-P para la ruta donde queremos descargar)
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer

#3. Renombrar el archivo (siempre se cogerá primero los llamados Index)
mv /var/www/html/adminer/adminer-4.8.1-mysql.php /var/www/html/adminer/index.php

#4. Modificar el grupo (-R recursivo)
chown -R www-data:www-data /var/www/html/adminer/index.php

#-----------------------------------------------------------------------------------------------------------------------------
#Crear DB 
mysql -u root <<< "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root <<< "CREATE DATABASE $DB_NAME"

#Crear User
mysql -u root <<< "DROP USER IF EXISTS $DB_USER@'%'"
mysql -u root <<< "CREATE USER $DB_USER@'%' IDENTIFIED BY '$DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'%'"

#-----------------------------------------------------------------------------------------------------------------------------
#Instalar GoAccess

apt update
apt install goaccess -y
#goaccess /var/log/apache2/access.log -c #sirve para ver las stats en terminal, para ejecutar quita la primera almohadilla

#Mejora de estadísticas
mkdir -p /var/www/html/stats

# -o (output) crea un archivo con otro formato, --log-format (opción de goaccess), --real-time-html (tiempo real) --daemonize (en segundo plano)
goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html --daemonize

#Creación y copia de un nuevo archivo conf y su despliegue en sites-available
cp ../conf/000-default-stats.conf /etc/apache2/sites-available

#Deshabilitamos el acceso al primer .conf
a2dissite 000-default.conf

#Habilitamos el acceso al nuevo .conf para el de stats
a2ensite 000-default-stats.conf

#creamos el archivo de usuario y contraseña -b para decirle que es bash (usar las variables) -c crear el archivo .htpasswd
htpasswd -bc /etc/apache2/.htpasswd $STATS_USERNAME $STATS_PASSWORD

#Modificar el propietario del directorio y el interior de var www html
chown -R www-data:www-data /var/www/html

#Reinicio de apache2
systemctl restart apache2

#--------------------------------------------------------------------------------------------------------------------------
#Creamos un archivo para .htaccess 
cp ../conf/000-default-htaccess.conf /etc/apache2/sites-available

a2dissite 000-default-stats.conf

a2ensite 000-default-htaccess.conf

#Reinicio de apache2
systemctl restart apache2

#Copiamos htaccess a /var/www/html/stats
cp ../conf/.htaccess /var/www/html/stats

#Reinicio de apache2
systemctl restart apache2