#!/bin/bash


# Debian Configuration and Updater version 1.4
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
read -p "Do you want to fix the secruity repos to archive repos? [y/n]" answerFixRepos
read -p "Do you want to install *ONLY* security updates to CentOS Linux now? [y/n] " answerSecUpdate
read -p "Do you want to install *ALL* updates to Ubuntu Linux now? [y/n] " answerUpdate
read -p "Do you want to turn off root login, Ipv6, keep boot as read only,and ignore ICMP broadcast requests and prevent XSS attacks? [y/n]" answermasshardening
read -p "Do you want to install Bastille [y/n]" answerBastille
read -p "Do you want to install Lynis [y/n]" answerLynis
}

# If script run with -a flag, all options will automatically default to yes

if [[ $1 = -a ]] ; then

    read -p "Are you sure you want to install all packages and configure everything by default? Only Security Updates will be installed [y/n] " answerWarning
    if [[ $answerWarning = y ]] ; then
        answerGoogleDNS=y
        answerFixRepos=y
        answerSecUpdate=y
        answermasshardening=y
        answerBastille=y
        answerLynis=y
        answerFail2ban=y
    else
        printf "Verify what you do and do not want done...."
        sleep 2
        questions
fi

else
    echo "unknown command"
    questions
fi

# Logic for update and configuration steps

if [[ $answerGoogleDNS = y ]] ; then

    echo nameserver 8.8.8.8 >> /etc/resolv.conf
    echo nameserver 8.8.4.4 >> /etc/resolv.conf
    echo nameserver 4.2.2.2 >> /etc/resolv.conf
    echo "Updated DNS resolutions to Google DNS, this task was completed at: " $(date) >> changes
fi

if  [[$answerFixRepos = y]] ; then
     #change old repos to archive.ubuntu so they work
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
    cat << EOF > /etc/apt/sources.list 
    #actual list
    deb http://archive.debian.org/debian-archive/debian/ lenny main contrib non-free
    deb http://archive.debian.org/debian-security/ lenny/updates main contrib non-free
    EOF
    echo "Updated Source list, this task was completed at: " $(date) >> changes
fi

if [[ $answerUpdate = y ]] ; then

    printf "Updating Debain, this stage may take about an hour to complete...Hope you have some time to burn...
    "
    sudo apt-get update -qq && apt-get -y upgrade -qq && apt-get -y dist-upgrade -qq && apt-get -y purge -qq && apt-get -y autoremove -qq && apt-get -y clean -qq
fi

if [[ $answermasshardening = y ]] ; then
    #disable rootlogin
    sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config  #automated above lines for ssh config
    #ignore ICMP/Pings
    sudo echo Ignore ICMP request: >> /etc/sysctl.conf
    sudo echo net.ipv4.icmp_echo_ignore_all = 1 >> /etc/sysctl.conf
    sudo echo Ignore Broadcast request: >> /etc/sysctl.conf
    sudo echo net.ipv4.icmp_echo_ignore_broadcasts = 1 >> /etc/sysctl.conf
    sysctl -p
fi

if [[ $answerBastille = y ]] ; then
    sudo apt-get install bastille perl-tk

if [[ $answerLynis = y ]] ; then
    wget https://cisofy.com/files/lynis-1.6.4.tar.gz -O lynis.tar.gz
    tar -zxvf lynis.tar.gz
fi

function pause () {
        read -p "$*"
}

pause '
Press [Enter] key to exit...
'
