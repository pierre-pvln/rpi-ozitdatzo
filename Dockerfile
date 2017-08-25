FROM resin/rpi-raspbian

MAINTAINER Pierre Veelen <pierre@pvln.nl>

# ==========================================
# START OF INSTALLING UTILITIES AND DEFAULTS
# ==========================================

RUN sudo apt-get update && sudo apt-get install -y \
    apt-utils \
    nano \
    ssh && \
	sudo apt-get upgrade && \
    sudo apt-get clean && \ 
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
	 
# =============================
# END OF UTILITIES AND DEFAULTS
# =============================

# ===========================
# START OF INSTALLING APACHE2
# ===========================
#
# Inspiration: https://writing.pupius.co.uk/apache-and-php-on-docker-44faef716150
#

# get variables from commandline and set default values
ARG MY_APACHE2_SERVERNAME='def-server-name'
ARG MY_APACHE2_SITENAME='def-site-name'

# Install apache2 and cleanup afterwards
#
RUN sudo apt-get update && sudo apt-get install -y \
     apache2 && \
    sudo apt-get upgrade && \
	sudo apt-get clean && \ 
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable apache mods.
RUN a2enmod rewrite

# Set up the apache environment variables
#
ENV APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid 

# Expose apache2 on port 80
#
EXPOSE 80

# Copy this repo into place
#
ADD ./site/default /var/www/$MY_APACHE2_SITENAME

# set ownership of files
#
RUN chown -Rf $APACHE_RUN_USER:$APACHE_RUN_GROUP /var/www/$MY_APACHE2_SITENAME

# Update the default apache site with the config we created.
#
ADD ./configs/apache2-config.conf /etc/apache2/sites-enabled/000-default.conf

# Change folder to sitename -> change  var/www/site to var/www/$MY_APACHE2_SITENAME
# sed -i "s/TextFrom/TextTo/" inWhichFile
# \/ is used to escape the / in the file path
#
RUN sed -i "s/var\/www\/site/var\/www\/$MY_APACHE2_SITENAME/" /etc/apache2/sites-enabled/000-default.conf

# TODO CHANGE WEBSITE SERVERNAME TO PREVENT WARNING

# =========================
# END OF INSTALLING APACHE2
# =========================

# ========================
# START OF INSTALLING PHP5
# ========================

# Install php5 and cleanup afterwards
#
RUN sudo apt-get update &&  sudo apt-get install -y \
	 libapache2-mod-php5 \
	 php5 \ 
	 php-pear \
	 php5-xcache \
	 php5-mysql \
	 php5-curl \
	 php5-gd && \
    sudo apt-get upgrade && \
	sudo apt-get clean && \ 
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Update the PHP.ini file, enable <? ?> tags and quieten logging.
#
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini

# Enable apache mods for PHP.
#
RUN a2enmod php5

# ======================
# END OF INSTALLING PHP5
# ======================

# =========================
# START OF INSTALLING MYSQL
# =========================
#
# Inspiration: https://stackoverflow.com/questions/32145650/how-to-set-mysql-username-in-dockerfile/32146887#32146887
#
ARG MY_MYSQL_SERVER_ROOT_PASSWORD='def-root'

#DEBUG
#=====
# save info to file
RUN echo $MY_MYSQL_SERVER_ROOT_PASSWORD > /root/MY_MYSQL_SERVER_ROOT_PASSWORD.txt

#RUN { \ echo mysql-server-5.5 mysql-server/root_password password $MY_MYSQL_SERVER_ROOT_PASSWORD; \
#        echo mysql-server-5.5 mysql-server/root_password_again password $MY_MYSQL_SERVER_ROOT_PASSWORD; \
#    } | sudo debconf-set-selections \
#    && sudo apt-get update && sudo apt-get install -y \
#        mysql-server && \
#    sudo apt-get clean && \ 
#    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#  Install mysql-server and cleanup afterwards
#
RUN { \
        echo mysql-server-5.5 mysql-server/root_password password 'root'; \
        echo mysql-server-5.5 mysql-server/root_password_again password 'root'; \
    } | sudo debconf-set-selections \
    && sudo apt-get update && sudo apt-get install -y \
        mysql-server && \
    sudo apt-get upgrade && \
	sudo apt-get clean && \ 
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
# TODO: include mysql_secure_installation in container 
#
#RUN sudo apt-get update && \
#    sudo mysql_secure_installation && \
#    sudo apt-get clean && \ 
#    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
	
#TEST
#====
# Copy MySQL test scripts to home directory
#
ADD ./site/scripts/mysql /root/mysql
RUN chmod -R +x /root/mysql/*.sh

# =======================
# END OF INSTALLING MYSQL
# =======================

# ======================================
# START OF INSTALLING JOOMLA! RESTORE FILES
# ======================================

# Copy kickstart files to website
#
ADD ./site/kickstart /var/www/$MY_APACHE2_SITENAME

# Set ownership of files or kickstart will not work properly
#
RUN chown -Rf $APACHE_RUN_USER:$APACHE_RUN_GROUP /var/www/$MY_APACHE2_SITENAME

# Copy archive copy scripts to home directory
#
ADD ./site/scripts/archive /root/archive
RUN chmod -R +x /root/archive/*.sh

# ======================================
# END OF INSTALLING JOOMLA! RESTORE FILES
# ======================================

#
# ENTRYPOINT & CMD
# ======
# Cancel pre-defined start-up instruction and allow us to use our own.
#ENTRYPOINT []

ADD ./entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/bin/bash","entrypoint.sh"]
 
# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND

#CMD /bin/bash
