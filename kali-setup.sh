#!/bin/bash

# Script is designed to install and set up multiple tools on a brand new kali install.
# Barely tested, but works decently well.

GREEN="\32[1;31m"
RESETG="\032[0m"
RED="\033[1;31m"
RESET="\033[0m"

if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
else
	sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove
	sudo apt install at bloodhound gedit golang seclists testssl.sh assetfinder sublist3r responder curl dnsrecon enum4linux feroxbuster gobuster impacket-scripts nbtscan nikto nmap onesixtyone oscanner redis-tools smbclient smbmap snmp sslscan sipvicious testssl.sh tnscmd10g whatweb wkhtmltopdf wordlists -y
	python3 -m pip install --upgrade pip
	pip3 install shceck
	cd /opt
	sudo git clone --depth 1 https://github.com/drwetter/testssl.sh.git
	sudo git clone https://github.com/leebaird/discover.git
	sudo git clone https://github.com/carlospolop/PEASS-ng.git
	wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
	sudo git clone https://github.com/CiscoCXSecurity/rdp-sec-check.git
	sudo git clone https://github.com/evict/SSHScan.git
	sudo git clone https://github.com/carlospolop/hacktricks.git
	sudo git clone https://github.com/rbsec/dnscan
	sudo git clone https://github.com/six2dez/reconftw
	sudo git clone https://github.com/MindPointGroup/cloudfrunt
	cd /opt/cloudfrunt
	pip install -r requirements.txt
	cd /opt
	sudo git clone https://github.com/swisskyrepo/PayloadsAllTheThings
	sudo git clone https://github.com/dirkjanm/mitm6.git
	cd /opt/mitm6
	pip install -r requirements.txt
	cd /opt
	sudo gzip -d /usr/share/wordlists/rockyou.txt.gz
	cpan install Encoding::BER
  cd opt/reconftw
  sudo bash install.sh
  cd /opt
  sudo git clone https://github.com/fox-it/BloodHound.py.git
  cd Bloodhound.py
  python setup.py install
  cd /opt
  git clone https://github.com/gwen001/cloudflare-origin-ip
  cd cloudflare-origin-ip
  pip3 install -r requirements.txt
  cd /opt
  sudo git clone https://github.com/cddmp/enum4linux-ng.git
  sudo apt install smbclient python3-ldap3 python3-yaml python3-impacket
  sudo git clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git
  cd Windows-Exploit-Suggester/
  sudo wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
  sudo python2 get-pip.py
  python2 -m pip install --user xlrd==1.1.0
  sudo windows-exploit-suggester.py --update
  
  
  
  

	echo -e  "Please add api keys for theHarvester in /etc/theHarvester/api-keys.yaml \n 
    Please install the following cpan module: cpan install Encoding::BER using the following command: cpan install Encoding::BER\n
		If there is an issue with reconftw, do the following 2 lines: \n
    Please install GoLang 1.15.0+ & paths correctly set ("$GOPATH", "$GOROOT")\n
		After verifying go is correctly installed, run: cd opt/reconftw && sudo ./install.sh \n
		Add #!/usr/bin/python3 to the top of /opt/mitm6/mitm6/mitm6.py"
	
fi

# Misc notes
# Please install the following cpan module: cpan install Encoding::BER using the following command: cpan install Encoding::BER\n
# I don't remember which tools needs the above line, but it is in the install script now.

#Fix windows-exploit-suggester information is on this page: https://github.com/AonCyberLabs/Windows-Exploit-Suggester/issues/43
