#!/bin/bash

# Debian Configuration and Updater version 1.2
# This script is intended for use in Debian Linux Installations
# Thanks to Pashapasta for the script template, check out the Kali version at https://github.com/PashaPasta/KaliUpdater/blob/master/KaliConfigAndUpdate.sh
# Please contact dteo827@gmail.com with bugs or feature requests

printf "

                    #############################
                    # Debian Security & Updates #
                    #############################
                    
                   #################################
                   #This script MUST be run as root#
                   #################################
                    
    ##############################################################
    # Welcome, you will be presented with a few questions, please#
    #          answer [y/n] according to your needs.             #
    ##############################################################\n\n"


#initialize bastille & fail2ban as not installed
bastilleinstalled = n
fail2baninstalled = n

# Questions function
function questions() {
read -p "Do you want to add Google's and Level3's Public DNS to the resolv.conf file? [y/n]" answerGoogleDNS
read -p "Do you want to turn off root login, Ipv6, keep boot as read only,and ignore ICMP broadcast requests? [y/n]" answerWegettinghard
read -p "Do you want to install updates to Debian Linux now? [y/n] " answerUpdate
read -p "Do you want to install Bastille [y/n]" answerBastille
read -p "Do you want to install Fail2ban [y/n]" answerFail2ban
read -p "Do you want to install Curl [y/n]" answerCurl
read -p "Do you want to setup OpenVAS? IF THIS IS A SERVER INSTALL SELECT NO!!! (Note: You will be prompted to enter a password for the OpenVAS admin user, this process may take up to an hour) [y/n] " answerOpenVAS
read -p "Do you want to update Nikto's definitions? [y/n] " answerNikto
read -p "Do you want to install PHP5? [y/n] " answerPhp
read -p "Do you want to install Mysql? [y/n]" answerMysql
read -p "Do you want to download (not install) Leopard Flower [y/n]" answerLeopardFlower
}

# Flags!!!!
# If script run with -a flag, all options will automatically default to yes
# IF script run with -h flag, README.md will be displayed
# If script run with -s flag, only items that should be used on a server install will be set to yes

if [[ $1 = -a ]] ; then

    read -p "Are you sure you want to install all packages and configure everything by default? [y/n] " answerWarning
    if [[ $answerWarning = y ]] ; then
        answerGoogleDNS=y
        answerWegettinghard=y
        answerUpdate=y
        answerBastille=y
        answerFail2ban=y
        answerOpenVAS=y
        answerCurl=y
        answerNikto=y
        answerPhp=y
        answerMysql=y
        answerLeopardFlower=y
    else
        printf "Verify would you do and do not want done...."
        sleep 2
        questions
fi

elif [[ $1 = -s ]] ; then

        answerGoogleDNS=y
        answerWegettinghard=y
        answerUpdate=y
        answerBastille=y
        answerFail2ban=y
        answerCurl=y
        answerPhp=y
        answerMysql=y
        answerLeopardFlower=y

elif [[ $1 = -h ]] ; then

    cat README.md
    exit
else

    questions
fi

# Logic for update and configuration steps

if [[ $answerGoogleDNS = y ]] ; then

    sudo echo nameserver 8.8.8.8 >> /etc/resolv.conf
    sudo echo nameserver 8.8.4.4 >> /etc/resolv.conf
    sudo echo nameserver 4.2.2.2 >> /etc/resolv.conf
fi

if [[ $answerWegettinghard = y ]] ; then
    sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config  #automated above lines for ssh config
    sudo echo LABEL=/boot     /boot     ext2     defaults,ro     1 2 >> /etc/fstab
    sudo echo Ignore ICMP request: >> /etc/sysctl.conf
    sudo echo net.ipv4.icmp_echo_ignore_all = 1 >> /etc/sysctl.conf
    sudo echo Ignore Broadcast request: >> /etc/sysctl.conf
    sudo echo net.ipv4.icmp_echo_ignore_broadcasts = 1 >> /etc/sysctl.conf
    sysctl -p
fi

if [[ $answerUpdate = y ]] ; then

    printf "Updating Debain, this stage may take about an hour to complete...Hope you have some time to burn...
    "
    sudo apt-get update -qq && apt-get -y upgrade -qq && apt-get -y dist-upgrade -qq && apt-get -y purge -qq && apt-get -y autoremove -qq && apt-get -y clean -qq
fi

if [[ $answerBastille = y ]] ; then
    sudo apt-get install bastille perl-tk
fi

if [[ $answerFail2ban = y ]] ; then
    sudo apt-get install fail2ban
fi

if [[ $answerOpenVAS = y ]] ; then
    sudo echo "deb http://download.opensuse.org/repositories/security:/OpenVAS:/UNSTABLE:/v5/Debian_6.0/ ./" >> /etc/apt/sources.list
    sudo apt-key adv --keyserver hkp://keys.gnupg.net --recv-keys BED1E87979EAFD54
    sudo apt-get -y install greenbone-security-assistant gsd openvas-cli openvas-manager openvas-scanner openvas-administrator sqlite3 xsltproc
    sudo apt-get -y install texlive-latex-base texlive-latex-extra texlive-latex-recommended htmldoc
    sudo apt-get -y install alien rpm nsis fakeroot
# not sure about what's below....
    echo ...Starting OpenVAS setup...Please be ready to enter desired OpenVAS admin password
    mkdir /var/log/Updater
    openvas-setup
    openvas-setup --check-install > /var/log/Updater/openvas-info.log
    openvas-nvt-sync
    openvas-feed-update
fi

if [[ $answerCurl = y ]] ; then
    sudo apt-get install curl
fi

if [[ $answerNikto = y ]] ; then
    wget https://www.cirt.net/nikto/nikto-2.1.5.tar.bz2
    tar xjf nikto-2.1.5.tar.bz2
    chmod +x /nikto-2.1.5/nikto.pl
    printf " To start Nikto run 'cd nikto-2.1.4' and 'perl nikto.pl'
    "
fi

if [[ $answerPhp = y ]] ; then
    sudo apt-get install php5-mysql
fi

if [[ $answerLeopardFlower = y ]] ; then
    wget http://iweb.dl.sourceforge.net/project/leopardflower/Source/lpfw-0.4-src.zip
fi

if [[ $answerMysql = y ]] ; then
    sudo apt-get install mysql-server
    printf " Starting mysql_secure_installation script...standby for input..."
    mysql_secure_installation
fi

# Not sure about this part
# If OpenVAS was installed, check for error file, if present, print alert

function filecheck () {
    file="/var/log/Updater/openvas-info.log"

    if [ -f "$file" ] ; then
        printf "Check /var/log/Updater/openvas-info.log for errors and recommendations
        "
    fi
}
if [[ $answerOpenVAS = y ]] ; then

file="/var/log/Updater/openvas-info.log"

    filecheck
    printf "Note: OpenVAS user name is [admin]
    "
    sleep 3
fi

function pause () {
        read -p "$*"
}

if [[ $bastilleinstalled = y ]] ; then
    read -p "Do you want to configure Bastille? [y/n]" answerConfigBastille
fi

if [[ answerConfigBastille = y ]] ;
    printf"Here we go....

        #################################
        #This is what you need to select#
        #################################

#File permissions module: Yes (suid)
#Disable SUID for mount/umount: Yes
#Disable SUID on ping: Yes
#Disable clear-text r-protocols that use IP-based authentication? Yes
#Enforce password aging? No (situation dependent, I have no users accessing my machines except me, and I only allow ssh keys)
#Default umask: Yes
#Umask: 077
#Disable root login on tty’s 1-6: No
#Password protect GRUB prompt: No (situation dependent, I’m on a VPS and would like to get support in case I need it)
#Password protect su mode: Yes
#default-deny on tcp-wrappers and xinetd? No
#Ensure telnet doesn’t run? Yes
#Ensure FTP does not run? Yes
#Display authorized use message? No (situation dependent, if you had other users, Yes)
#Put limits on system resource usage? Yes
#Restrict console access to group of users? Yes (then choose root)
#Add additional logging? Yes
#Setup remote logging if you have a remote log host, I don’t so I answered No
#Setup process accounting? Yes
#Disable acpid? Yes
#Deactivate nfs + samba? Yes (situation dependent)
#Stop sendmail from running in daemon mode? No (I have this firewalled off, so I’m not concerned)
#Deactivate apache? Yes
#Disable printing? Yes
#TMPDIR/TMP scripts? No (if a multi-user system, yes)
#Packet filtering script? No (we configured the firewall previously)
#Finished? YES! & reboot"
    sudo bastille
fi

if [[ fail2baninstalled = y ]] ; then
    read -p "Do you want to configure fail2ban? [y/n]" answerConfigfail2ban
fi

pause '
    Press [Enter] key to exit...
     '
