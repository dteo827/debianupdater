#!/bin/bash
# Debian 5 Lenny Configuration and Updater version 2.0
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
read -p "Is this the first time this script has been run? [y/n]" answerFirstRun
read -p "Do you want to turn off root login, Ipv6, keep boot as read only,and ignore ICMP broadcast requests and prevent XSS attacks? [y/n]" answerrootkits
read -p "Do you want to install Lynis [y/n]" answerLynis
read -p "Do you want to install Clamav [y/n]" answerClamav
}

# If script run with -a flag, all options will automatically default to yes

echo "version"
lsb_release -r >> file
uname -r >> file
echo date >> file
echo
echo "my name" >> file
echo
echo dpkg -l >> file

questions

# Logic for update and configuration steps
if [[ $answerFirstRun = y ]] ; then
	answerUpdateBash=y 
	answerGoogleDNS=y
    answerFixRepos=y
fi
	
if [[ $answerUpdateBash = y ]] ; then
	wget --no-check-certificate https://raw.githubusercontent.com/dteo827/debainupdater/master/hardscript.sh/
    	cd /src
    	wget http://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz
    	#download all patches
    	for i in $(seq -f "%03g" 1 28); do wget http://ftp.gnu.org/gnu/bash/bash-4.3-patches/bash43-$i; done
    	tar zxvf bash-4.3.tar.gz
    	cd bash-4.3
    	#apply all patches
    	for i in $(seq -f "%03g" 1 28); do patch -p0 < ../bash43-$i; done
    	#build and install
    	./configure --prefix=/ && make && make install
    	cd /root
    	rm -r src
fi

if [[ $answerGoogleDNS = y ]] ; then

    echo nameserver 8.8.8.8 >> /etc/resolv.conf
    echo nameserver 8.8.4.4 >> /etc/resolv.conf
    echo "Updated DNS resolutions to Google DNS, this task was completed at: " $(date) >> changes
fi

if  [[ $answerFixRepos = y ]] ; then
    #change old repos to archive.ubuntu so they work
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
    #actual list
    echo deb http://archive.debian.org/debian-archive/debian/ lenny main contrib non-free > /etc/apt/sources.list 
    echo deb http://archive.debian.org/debian-security/ lenny/updates main contrib non-free >> /etc/apt/sources.list 
	echo deb http://archive.debian.org/debian/ lenny main contrib non-free >> /etc/apt/sources.list 
	echo deb http://archive.debian.org/debian-backports/ lenny-backports main >> /etc/apt/sources.list 
	echo deb http://archive.debian.org/debian-backports/ lenny-backports-sloppy main >> /etc/apt/sources.list
	echo "If there is an error in the following command, update the keys with:
	sudo apt-key list | grep expired
	You will get a result similar to the following:
	pub   4096R/BE1DB1F1 2011-03-29 [expired: 2014-03-28]
	The key ID is the bit after the / i.e. BE1DB1F1 in this case.
	To update the key, run
	sudo apt-key adv --recv-keys --keyserver keys.gnupg.net BE1DB1F1"
	apt-get update
	###^does not actually donwload anything, only updates the list of avalible packages
    echo "Updated Source list, this task was completed at: " $(date) >> changes
fi


if [[ $answerrootkits = y ]] ; then
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
	cd ~
fi

if [[ $answerLynis = y ]] ; then
    wget --no-check-certificate https://cisofy.com/files/lynis-2.1.1.tar.gz
	tar -xzvf lynis-2.1.1.tar.gz
	cd lynis
	chmod a+x lynis
	./lynis audit system -Q

	echo "Warnings:\n"  > lynis_log
	cat /var/log/lynis-report.dat | grep warning | sed –e ‘s/warning\[\]\=//g’ >> lynis_log
	echo "Suggestions:\n " >> lynis_log
	cat /var/log/lynis-report.dat | grep suggestion | sed –e ‘s/suggestion\[\]\=//g’ >> lynis_log
	echo "available_shells:\n" >> lynis_log
	cat /var/log/lynis-report.dat | grep available_shell | sed –e ‘s/available_shell\[\]\=//g’ >> lynis_log
	echo "To run lynis, go to lynis directory and: ./lynis audit system -Q"
fi

if [[ $answerClamav = y ]] ; then
    sudo apt-get install clamav clamav-base clamav-daemon clamav-freshclam openssl libxml2 libpcre3 libclamav2 build-essential
	nano /usr/local/etc/freshclam.conf
	mkdir /usr/local/share/clamav
	echo "Replace UID:GID with Clamavs user ID and group ID from /etc/passwd & /etc/group "
	echo "chown UID:GID /var/lib/clamav & chmod 775 /var/lib/clamav"
	echo "chown UID:GID /usr/local/share/clamav & chmod 777 /usr/local/share/clamav"
	freshclam
	clamscan -r /etc /tmp /home/* /root

fi

echo "version"
lsb_release -r >> file
uname -r >> file
echo date >> file
echo
echo "my name" >> file
echo
echo dpkg -l >> file

function pause () {
        read -p "$*"
}

pause '
Press [Enter] key to exit...
'
