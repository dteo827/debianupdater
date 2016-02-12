#!/bin/bash
cd ~
wget http://downloads.sourceforge.net/project/rkhunter/rkhunter/1.4.2/rkhunter-1.4.2.tar.gz
tar xzvf rkhunter*
cd rkhunter*
sudo ./installer.sh --layout /usr --install
sudo apt-get update
sudo apt-get install binutils libreadline5 libruby1.9 ruby ruby1.9 ssl-cert unhide.rb mailutils 
sudo apt-get install prelink
sudo rkhunter --versioncheck
sudo rkhunter --update
sudo rkhunter --propupd
#only shows warning to screen
sudo rkhunter -c --enable all --disable none --rwo
#shows everything
#sudo rkhunter -c --enable all --disable none
#cat /var/log/rkhunter.log | grep Warning
#https://www.digitalocean.com/community/tutorials/how-to-use-rkhunter-to-guard-against-rootkits-on-an-ubuntu-vps


# install chkrootkit
apt-get install chkrootkit
sudo chkrootkit
