#!/bin/bash

# Debian Configuration and Updater version 1.3
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

# Questions function
function questions() {
read -p "Do you want to add Google's and Level3's Public DNS to the resolv.conf file? [y/n]" answerGoogleDNS
read -p "Do you want to turn off root login, Ipv6, keep boot as read only,and ignore ICMP broadcast requests? [y/n]" answerWegettinghard
read -p "Do you want to install updates to Debian Linux now? [y/n] " answerUpdate
read -p "Do you want to install Lynis [y/n]" answerLynis
read -p "Do you want to install Fail2ban [y/n]" answerFail2ban
#read -p "Do you want to update Nikto's definitions? [y/n] " answerNikto
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
        answerLynis=y
        answerFail2ban=y
        answerOpenVAS=y

    else
        printf "Verify would you do and do not want done...."
        sleep 2
        questions
fi

elif [[ $1 = -s ]] ; then

        answerGoogleDNS=y
        answerWegettinghard=y
        answerUpdate=y
        answerLynis=y
        answerFail2ban=y
else
    questions
fi

# Logic for update and configuration steps

if [[ $answerGoogleDNS = y ]] ; then

    echo nameserver 8.8.8.8 >> /etc/resolv.conf
    echo nameserver 8.8.4.4 >> /etc/resolv.conf
    echo nameserver 4.2.2.2 >> /etc/resolv.conf
fi

if [[ $answerWegettinghard = y ]] ; then
    #Updating Source Repositories
    echo deb http://http.debian.net/debian/ squeeze main contrib non-free >> /etc/apt/sources.list
    echo deb-src http://http.debian.net/debian/ squeeze main contrib non-free >> /etc/apt/sources.list
    echo deb http://http.debian.net/debian squeeze-lts main contrib non-free >> /etc/apt/sources.list
    echo deb-src http://http.debian.net/debian squeeze-lts main contrib non-free >> /etc/apt/sources.list
    echo deb http://ftp.de.debian.org/debian squeeze-lts main  >>  /etc/apt/sources.list
    wget http://http.us.debian.org/debian/pool/main/d/debian-security-support/debian-security-support_2014.12.17~bpo60+1_all.deb -O debian-security-support.deb
    ./debian-security-support.deb

    #disable rootlogin
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config  #automated above lines for ssh config
    #ignore ICMP/Pings
    echo Ignore ICMP request: >> /etc/sysctl.conf
    echo net.ipv4.icmp_echo_ignore_all = 1 >> /etc/sysctl.conf
    echo Ignore Broadcast request: >> /etc/sysctl.conf
    echo net.ipv4.icmp_echo_ignore_broadcasts = 1 >> /etc/sysctl.conf
    sysctl -p
fi

if [[ $answerUpdate = y ]] ; then

    printf "Updating Debain, this stage may take about an hour to complete...Hope you have some time to burn...
    "
    apt-get update -qq && apt-get -y upgrade -qq && apt-get -y purge -qq && apt-get -y autoremove -qq && apt-get -y clean -qq
    apt-get install --only-upgrade bash
    
fi

if [[ $answerLynis = y ]] ; then
    wget https://cisofy.com/files/lynis-1.6.4.tar.gz -O lynis.tar.gz --no-check-certificate
    tar -zxvf lynis.tar.gz

fi

if [[ $answerFail2ban = y ]] ; then
    apt-get install fail2ban
fi

function pause () {
        read -p "$*"
}

pause '
    Press [Enter] key to exit...
     '
