#!/bin/bash
cp /etc/apt/sources.list /etc/apt/sources.list.old
#SECCDC sources > /etc/apt/sources.list 
deb http://archive.debian.org/debian/ lenny main non-free contrib >> /etc/apt/sources.list 
deb-src http://archive.debian.org/debian/ lenny main non-free contrib >> /etc/apt/sources.list 
# Volatile: >> /etc/apt/sources.list 
deb http://archive.debian.org/debian-volatile lenny/volatile main contrib non-free >> /etc/apt/sources.list 
deb-src http://archive.debian.org/debian-volatile lenny/volatile main contrib non-free >> /etc/apt/sources.list 
# Backports: >> /etc/apt/sources.list 
deb http://archive.debian.org/debian-backports lenny-backports main contrib non-free >> /etc/apt/sources.list 
# Previously announced security updates: >> /etc/apt/sources.list 
deb http://archive.debian.org/debian-security lenny/updates main >> /etc/apt/sources.list 

deb http://archive.debian.org/debian-archive/debian/ lenny main contrib non-free >> /etc/apt/sources.list 
deb http://archive.debian.org/debian-security/ lenny/updates main contrib non-free >> /etc/apt/sources.list 
deb http://archive.debian.org/debian/ lenny main contrib non-free >> /etc/apt/sources.list 
deb http://archive.debian.org/debian-backports/ lenny-backports main >> /etc/apt/sources.list 
deb http://archive.debian.org/debian-backports/ lenny-backports-sloppy main >> /etc/apt/sources.list
