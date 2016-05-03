# This Dockerfile leveraged work by Mark Shust <mark.shust@mageinferno.com>
# https://github.com/mageinferno/

FROM php:7.0-apache
MAINTAINER Alan Kent <alan.james.kent@gmail.com>
ARG MAGENTO_REPO_USERNAME
ARG MAGENTO_REPO_PASSWORD


ADD scripts /scripts

########### Apache and PHP Setup ########### 

# Environment variables from /etc/apache2/apache2.conf
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid

RUN sh -x /scripts/install-php-extras

########### MySQL Setup ########### 

# I check latest version number at https://hub.docker.com/_/mariadb/
# (old versions are removed from site - only recent version is kept)
ENV MARIADB_MAJOR 10.0
ENV MARIADB_VERSION 10.0.25+maria-1~jessie

RUN sh -x /scripts/install-mysql

########### SSHD ########### 

RUN sh -x /scripts/install-ssh
EXPOSE 22

########### NodeJS ########### 

RUN sh -x /scripts/install-nodejs

########### Samba ########### 

# Add Samba (don't start by default as it can slow things down)
# Mount on Windows using
#    NET USE M: \\192.168.99.100\magento2 magento /USER:magento
ENV SAMBA_START=0
RUN sh -x /scripts/install-samba
EXPOSE 445
EXPOSE 139
EXPOSE 135

########### Magento Setup ########### 

ENV MYSQL_ROOT_PASSWORD ""
ENV MYSQL_ALLOW_EMPTY_PASSWORD true
ENV MYSQL_DATABASE magento
ENV MYSQL_USER magento
ENV MYSQL_PASSWORD magento

ENV MAGENTO_USER magento
ENV MAGENTO_PASSWORD magento
ENV MAGENTO_GROUP magento

ENV APACHE_RUN_USER magento
ENV APACHE_RUN_GROUP magento

ENV MAGENTO_REPO_USERNAME "$MAGENTO_REPO_USERNAME"
ENV MAGENTO_REPO_PASSWORD "$MAGENTO_REPO_PASSWORD"

RUN sh -x /scripts/install-magento

ENV MAGENTO_REPO_USERNAME ""
ENV MAGENTO_REPO_PASSWORD ""

# Install Gulp
RUN sh -x /scripts/install-gulp
EXPOSE 3000
EXPOSE 3001

# Add mount volume points, but often not used.
VOLUME /magento2/app/code
VOLUME /magento2/app/design
VOLUME /magento2/app/i18n

# Add some helper modules (optional)
ADD AlanKent /magento2/app/code/AlanKent
RUN chown -R magento:magento /magento2/app/code/AlanKent
RUN /usr/local/bin/mysql.server start \
 && sudo -u magento sh -c '/magento2/bin/magento setup:upgrade' \
 && rm -rf /magento2/var/* \
 && /usr/local/bin/mysql.server stop

# Set default environment.
WORKDIR /magento2
ENV SHELL /bin/bash
ENV PATH PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/magento2/bin

# Don't ask for passwords when running sudo.
RUN echo "magento ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Entrypoint
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
