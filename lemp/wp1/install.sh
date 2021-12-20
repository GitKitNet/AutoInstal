





#
# running mysql_secure_installation
#
echo 'running mysql_secure_installation ..'
installationMySql=$(expect -c '
spawn /usr/bin/mysql_secure_installation
expect "Enter current password for root (enter for none):"
send "'$mysqlPass'\r"
expect "Change the root password?"
send "n\r"
expect "Remove anonymous users?"
send "y\r"
expect "Disallow root login remotely?"
send "y\r"
expect "Remove test database and access to it?"
send "y\r"
expect "Reload privilege tables now?"
send "y\r"
expect eof
')
echo "$installationMySql" > /dev/null 2>&1
echo "+-----------------------------+"

