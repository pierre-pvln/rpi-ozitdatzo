#!/bin/bash

# Start MYSQL
# inspiration https://stackoverflow.com/questions/9083408/fatal-error-cant-open-and-lock-privilege-tables-table-mysql-host-doesnt-ex
#
chown -R mysql /var/lib/mysql
chgrp -R mysql /var/lib/mysql
service mysql start

# Create Joomla! entries and tables in MySQL database
#
/usr/bin/mysql -uroot -proot --execute="create database joomla_db;
    grant all on joomla_db.* to joomla@'localhost' identified by 'joomla';
    grant all on joomla_db.* to joomla@'%' identified by 'joomla'; 
    flush privileges;"

# start vsftp service
#
#service vsftpd start

# Start apache2
#
/usr/sbin/apache2ctl -D FOREGROUND

