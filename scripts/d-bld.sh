#!/bin/bash

# set excecute mode for shell scripts 
chmod +x *.sh

# reads and executes commands from filename in the current shell environment
source set_bld.sh
source set_apache2.sh
source set_mysql.sh

# use environment variables during build
docker build --tag $my_build_name --build-arg MY_APACHE2_SERVERNAME=$servername --build-arg MY_APACHE2_SITENAME=$websitename --build-arg MY_MYSQL_SERVER_ROOT_PASSWORD=$my_mysql_root_pw ../
