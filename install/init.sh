#!/bin/bash
# Install Selenium + Chrome + Java Centos

#================================================
# Variable
#================================================
set -e
GREEN='\033[0;32m'
NC='\033[0m' # No Color

#================================================
# Check sudo user
#================================================

if [[ "$EUID" -ne 0 ]]; then
    printf "${GREEN}Please run as root or sudo.\n${NC}"
    exit 1;
fi

#============================================
# UnInstall Google Chrome
#============================================
ls -a | grep "google-chrome-" | grep -v grep | awk '{print $1}' | xargs -r rm
ls -a | grep "chromedriver_linux64" | grep -v grep | awk '{print $1}' | xargs -r rm
yum list installed | grep "google-chrome" | grep -v grep | awk '{print $1}' | xargs -r yum -y remove

#============================================
# Install Google Chrome
#============================================
wget --no-check-certificate --no-verbose http://dist.control.lth.se/public/CentOS-7/x86_64/google.x86_64/google-chrome-stable-108.0.5359.124-1.x86_64.rpm
yum -y install google-chrome-stable-108.0.5359.124-1.x86_64.rpm
#============================================
# Install Google Chromedriver
#============================================
wget https://chromedriver.storage.googleapis.com/108.0.5359.71/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
mv -f chromedriver /usr/local/bin
perl -pi -e 's/cdc_/dog_/g' /usr/local/bin/chromedriver
#============================================
# Install Selenium
#============================================
rm -rf selenium-server-standalone-3.6.0.jar
wget https://selenium-release.storage.googleapis.com/3.9/selenium-server-standalone-3.9.1.jar
mv selenium-server-standalone-3.9.1.jar /usr/local/bin
#============================================

systemctl enable httpd.service

#============================================
# Install Supervisor
#============================================
perl -pi -e 's/selenium-server-standalone-3.6.0.jar -enablePassThrough false/selenium-server-standalone-3.9.1.jar/g' /etc/supervisord.conf
supervisorctl reload
rm -f google-chrome-stable-108.0.5359.124-1.x86_64.rpm
service firewalld stop
#============================================
# Install Supervisor
#============================================
systemctl restart supervisord
#============================================
# Echo
#============================================
printf "${GREEN}java -jar /usr/local/bin/selenium-server-standalone-3.9.1.jar -timeout 60 & \n${NC}"
printf "${GREEN}vncserver \n${NC}"