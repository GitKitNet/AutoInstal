#!/bin/bash

# bash <(wget -O - raw.githubusercontent.com/numbnet/AutoInstall/master/WPinstall_v4.sh || curl -sL raw.githubusercontent.com/numbnet/AutoInstall/master/WPinstall_v4.sh)

clear
echo ""
echo -e "\e[34m==================NOTE========================\e[0m"
echo -e " \e[1;34m RUN the SCRIPT from ROOT USER"
echo " "
read -n1 -r -p "Press ENTER to continue..." key

if [ "$key" = '' ]; then
  {
     ping -c1 8.8.8.8  &> /dev/null
     if [ $? != 0 ]; then
     { 
       echo -e "\e[1;31mCheck your Internet connection\e[0m"
     }
     else 
     {
       echo "-----------Ready for installation----------------------------------------------------------------------------"
       echo "-----------Updating the source list--------------------------------------------------------------------------"
       apt-get update -y && apt-get upgrade -y
       sudo apt-get update  > /dev/null
        if [ $? == 0 ]; then
        {
           echo "---------------------------------------------------------------------------------------------------------"
           echo "----------------------------PART 1 STARTED---------------------------------------------------------------"
    echo "-----------------------------Domain Setup----------------------------------------------------------------"
    #add the packages name that you want to install or check in below array 
           read  -p  "Enter the Domain Name (for example rupin.com)" dname
           IP="127.0.0.1"
           sudo -- sh -c -e "echo '$IP $dname' >> /etc/hosts";
          if [ -z $dname ]; then {
            echo -e "\e[1;31mNo domain name given\e[0m"
            #exit 1
          }
          fi
         PATTERN="^([[:alnum:]]([[:alnum:]\-]{0,61}[[:alnum:]])?\.)+[[:alpha:]]{2,6}$"
          if [[ "$dname" =~ $PATTERN ]]; then
            DOMAIN=`echo $dname | tr '[A-Z]' '[a-z]'`
            echo "Creating hosting for:" $dname
          else
           echo -e "\e[1;31minvalid domain name\e[0m"
           #exit 1
          fi
          echo "-----------------------PART 1 completed succesfully--------------------------------------------------------"   
          echo "-----------------------------------------------------------------------------------------------------------"


      echo "---------------------------------------------------------------------------------------------------------"
           echo "----------------------------PART 2 STARTED----------------------------------------------------------------"
    echo "-----------------------------Lets start with Installaton--------------------------------------------------"
     #read  -s -p "Enter the password for the Database" dbpass
    dbpass="$(date +%s | sha256sum | base64 | head -c 22)"
    echo -e "Password for the Database: ${dbpass}"
    echo -e "Password for the Database: ${dbpass}">> ~/.akkaunts
    
    #add the packages name that you want to install or check in below array
     # apache2 apache2-bin apache2-data apache2-utils libapache2-mod-php7.3 libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap libjansson4 liblua5.2-0 libmagic-mgc libmagic1 php-common php7.3 php7.3-cli php7.3-common php7.3-json php7.3-opcache php7.3-readline ssl-cert
     #package=( mysql-server nginx php7.3-fpm php7.3-xml php7.3-bz2 php7.3-zip php7.3-mysql php7.3-intl php7.3-gd php7.3-curl php7.3-soap php7.3-mbstring php7.3-bcmath php-gd php7.3-gd php-ssh2)

    package=( mysql-server nginx php-fpm php-mysql php-gd php-ssh2 php-xml php-bz2 php-zip php-mysql php-intl php-gd php-soap php-mbstring php-bcmath)
    for var in "${package[@]}"
           do
     dpkg-query -W "${var}" > /tmp/wordpress-install.log 2> /tmp/wordpress-install-error.log
    
          if [ $? == 0 ]; then
               {
           echo "${var} is installed" 
        } else {
        if [ ${var} == "mysql-server" ]; then
       {
        echo "installing mysql-server now"
       # read  -s -p "Enter the password for the Database" dbpasswd
        echo "It will take time to install"
        sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $dbpass"
        sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $dbpass"
        sudo apt-get -y install mysql-server >> /tmp/wordpress-install.log 2>> /tmp/wordpress-install-error.log
            if [ $? == 0 ]; then {
                echo -e "-----------\e[1;32m ${var} was installed succesfully.\e[0m------------------------------------------" 
                echo "-------------------------------------------------------------------------------------------------------"
            } else {
               echo -e "\e[1;31m--ERROR--- There was problem while installing ${var}----\e[0m" 
               #exit 1
            }
           fi
      }
     fi
        echo "${var} is not installed"   
        echo "${var} is installing right now "
        sudo apt-get install ${var} -y  >> /tmp/filelog 2>> /tmp/error.log
         if [ $? == 0 ]; then {
            echo -e "-----------\e[1;32m${var} was installed succesfully.\e[0m------------------------------------------------" 
            echo "------------------------------------------------------------------------------------------------------------"
          } else {           
            echo -e "\e[1;31m--ERROR--- There was problem while installing ${var}----\e[0m" 
            #exit 1
          }   
         fi
         }
        fi    
      done
echo "-----------------------PART 2 completed succesfully----------------------------------------------------------------------"   
echo "-------------------------------------------------------------------------------------------------------------------------"




echo "-----------------------PART 3 STARTED-------------------------------------------------------------------------------------"
#Create a MySQL Database and User for WordPress
CON=$dname\_db
DBCON=$(echo $CON | sed -e 's/\./_/g' -e 's/-/_/g' -e 's/ /_/g')
DBHOST=localhost
DBNAME=$DBCON
DBUSER=wordpress
DBPASSWD=test123
echo -e "\n--- Setting up our MySQL user and db --------------------------------------------------------------------------------\n"
mysql -uroot -p$dbpass -e "CREATE DATABASE $DBNAME" >> /tmp/wordpress-mysql.log 2>> /tmp/wordpress-mysql-error.log
if [ $? == 0 ]; then
     {
          echo -e "\n--- \e[1;32m Successfully created the database\e[0m \e[1;36m $DBNAME \e[0m---------------------------------\n"
     }
    else
     {
        echo -e "\e[1;31munable to create the database please check the error log /tmp/wordpress-mysql-error.log\e[0m"
        #exit 1
     }    
fi
mysql -uroot -p$dbpass -e "CREATE USER $DBNAME@$DBHOST IDENTIFIED BY '$DPASSWD';" >> /tmp/wordpress-mysql.log 2>> /tmp/wordpress-mysql-error.log
if [ $? == 0 ]; then
     {
        echo -e "\n--- \e[1;32m Successfully created the user\e[0m \e[36m$DBNAME\e[0m \e[32mwith password \e[0m \e[1;36m $DBPASSWD \e[0m ---\n"
     }
    else
     {
        echo -e "\e[1;31munable to create username and password please check the error log /tmp/wordpress-mysql-error.log\e[0m"       
     }   
 fi
mysql -uroot -p$dbpass -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'" >> /tmp/wordpress-mysql.log 2>> /tmp/wordpress-mysql-error.log
if [ $? == 0 ]; then
     {
          echo -e "\n--- \e[32mSuccessfully granted the permission for the users\e[0m ------------------------------\n"
     }
    else
     {
        echo -e "\e[1;31munable to graant the permission \e[0m"
     }
fi 
mysql -uroot -p$dbpass -e FLUSH PRIVILEGES >> /tmp/wordpress-mysql.log 2>> /tmp/wordpress-mysql-error.log
echo  "-------------------------------- Successfully setup the Database Part ------------------------------------------"
echo "----------------------------------Part 3 completed Succesfully---------------------------------------------------"
echo "-----------------------------------------------------------------------------------------------------------------"



echo "------------------------------------------------------------------------------------------------------------------"
echo "----------------------------Installation of Wordpress-------------------------------------------------------------"
echo "----------------------------PART 4 STARTED------------------------------------------------------------------------"
#download wordpress
echo "Downloading the wordpress..........."
ls lates* >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
if [ $? == 0 ]; then
     {
          sudo mv latest.* /tmp/
     }
fi
sudo wget https://wordpress.org/latest.tar.gz >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
if [ $? == 0 ]; then
     {
          echo -e "\n--- \e[32mDownloaded the Wordpress Successfully\e[0m------------------------------------------------"

	 }
    else
     {
        echo -e "\e[1;31m unable to Download Wordpress\e[0m"
        #exit 1
     }    
fi
echo "......UnZip ....Configure of wp-config.php......--------------------------------------------------------------------"

#unzip wordpress 
tar -zxvf latest.tar.gz >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
#change dir to wordpress
cd wordpress >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
#copy file to backup file to config file
cp wp-config-sample.php wp-config.php >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$DBNAME/g" wp-config.php >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
perl -pi -e "s/username_here/$DBUSER/g" wp-config.php >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
perl -pi -e "s/password_here/$DBPASSWD/g" wp-config.php >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
echo "----------------------------PART 4 Completed Successfully------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------------------------"




echo "----------------------------PART 5 Setup of NGINX--------------------------------------------------------------------"
echo "--------------------Nginx Configurations-----------------------------------------------------------------------------"
cd ..
sudo mkdir -p /var/www/$dname 
sudo cp  -r wordpress/* /var/www/$dname/ 
sudo chown -R www-data:www-data /var/www/$dname /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
sudo chmod -R 755 /var/www/$dname /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
(
cat <<EOF
server {
        listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;

        root /var/www/$dname;
        index index.php index.html index.htm;

        server_name $dname;

        location / {
                # try_files \$uri \$uri/ =404;
                try_files \$uri \$uri/ /index.php?q=\$uri&\$args;
        }

        error_page 404 /404.html;

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
                root /usr/share/nginx/html;
        }

        location ~ \.php$ {
                try_files \$uri =404;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:/var/run/php5-fpm.sock;
                fastcgi_index index.php;
                include fastcgi_params;
        }
}

EOF
) >  /etc/nginx/sites-available/$dname.conf 

sudo ln -s /etc/nginx/sites-available/$dname.conf /etc/nginx/sites-enabled/
sudo service nginx restart  >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
 if [ $? == 0 ]; then
        {
         echo -e "-----------\e[32mNginx was succesfully configured.\e[0m--------------------------------------------" 
         echo "------------------------------------------------------------------------------------------------------"
        }
      else
       {
         echo -e "\e[1;31m--There was problem while configuring Ngnix please check log /tmp/wordpress-setup-error.log-------\e[0m" 
         exit 
       }   
      fi
sudo service php5-fpm restart >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
 if [ $? == 0 ]; then
        {
         echo -e "-----------\e[32mphp5-fpm was succesfully restarted\e[0m--------------------------------------------" 
         echo "-------------------------------------------------------------------------------------------------------"
        }
      else
       {
         echo -e "\e[1;31m--There was problem while restarting ph5-fpm please check log /tmp/wordpress-setup-error.log-------\e[0m" 
         #exit
       }   
      fi
 sudo rm -rf wordpress
 sudo rm -rf latest.tar.gz
echo "-----------------------------------------PART 5 Completed succesfully--------------------------------------------"
echo "-----------------------------------------------------------------------------------------------------------------"
echo -e "-----------------OPEN THE BROWSER AND TYPE  \e[36mhttp://$dname/wp-admin/install.php\e[0m---------------------"
echo -e "-----------------Make sure that ANY OTHER WEB SERVER IS NOT LISTENING ON PORT 80------------------------------"
echo "-----------------------------------------------------------------------------------------------------------------"

        }  
        else
        {
         echo -e "\e[1;31m---------can't update the source list--------\e[0m"
         #exit 1
        }
       fi
     }
     fi
  }
else
  {
   echo ""
   echo -e "\e[1;31m!!!!!!!!!!PLEASE press SPACE OR ENTER KEY ONLY!!!!!\e[0m"
   echo ""
  } 
fi

# exit
