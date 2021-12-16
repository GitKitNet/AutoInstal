#!/bin/bash
# GET ALL USER INPUT
echo "Domain Name (eg. example.com)?"
read DOMAIN

echo "Updating OS................."
sleep 2;
sudo apt-get update

echo "Installing Nginx"
sleep 2;
sudo apt-get install nginx -y
sudo apt-get install zip -y
sudo apt install unzip -y

echo "Sit back and relax :) ......"
sleep 2;
cd /etc/nginx/sites-available/
wget -O "$DOMAIN" https://goo.gl/s8pdtv
sed -i -e "s/example.com/$DOMAIN/" "$DOMAIN"
sed -i -e "s/www.example.com/www.$DOMAIN/" "$DOMAIN"
sudo ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/

echo "Setting up Cloudflare FULL SSL"
sleep 2;
sudo mkdir /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
cd /etc/nginx/
sudo mv nginx.conf nginx.conf.backup
wget -O nginx.conf https://goo.gl/n8crcR
sudo mkdir /var/www/"$DOMAIN"
cd /var/www/"$DOMAIN"
sudo su -c 'echo "<?php phpinfo(); ?>" |tee info.php'
cd ~
#wget wordpress.org/latest.zip
#unzip latest.zip
#mv /root/wordpress/* /var/www/"$DOMAIN"/
#rm -rf wordpress latest.zip

echo "Nginx server installation completed"
sleep 2;
cd ~
sudo chown www-data:www-data -R /var/www/"$DOMAIN"
sudo systemctl restart nginx.service

echo "lets install php 7.2 and modules"
sleep 2;
sudo apt install php7.2 php7.2-fpm -y
sudo apt-get -y install php7.2-fpm php7.2-curl php7.2-gd php7.2-imap php7.2-readline php7.2-common php7.2-recode php7.2-mysql php7.2-cli php7.2-curl php7.2-mbstring php7.2-bcmath php7.2-mysql php7.2-opcache php7.2-zip php7.2-xml php-memcached php-imagick php-memcache memcached graphviz php-pear php-xdebug php-msgpack  php7.2-soap

echo "Some php.ini tweaks"
sleep 2;
sudo sed -i "s/post_max_size = .*/post_max_size = 2000M/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 3000M/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 1000M/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/; max_input_vars = .*/max_input_vars = 5000/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/zlib.output_compression = Off/zlib.output_compression = on/" /etc/php/7.2/fpm/php.ini
sudo systemctl restart php7.2-fpm.service

echo "Instaling MariaDB"
sleep 2;
sudo apt install mariadb-server mariadb-client php7.2-mysql -y
sudo systemctl restart php7.2-fpm.service
sudo mysql_secure_installation
