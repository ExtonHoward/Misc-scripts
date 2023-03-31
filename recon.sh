#!/bin/bash

# Script is designed to automate some basic OSINT


domain=$1
GREEN="\32[1;31m"
RESETG="\032[0m"
RED="\033[1;31m"
RESET="\033[0m"

info_path=$domain/info
subdomain_path=$domain/subdomain
dns_path=$domain/dns
people_path=$domain/people



if [ "$1" == "" ]
then
	echo "You forgot the target domain"
	echo "Syntax: ./recon.sh example.com"
else
	if [ ! -d "$domain" ]; then
		mkdir $domain
		mkdir $info_path $subdomain_path $dns_path $people_path
	fi

	#Whois
	echo -e "${RED} [+] Running Whois...... ${RESET}"
	whois $1 > $info_path/whois.txt
	
	#DNS	
	echo -e "${RED} [+] Enumerating DNS...... ${RESET}"
#	echo -e "${RED} [+] Running DNSrecon...... ${RESET}"
#	dnsrecon -d $domain | tee $dns_path/dnsrecon.txt

	echo -e "${RED} [+] Running DNScan...... ${RESET}"
	dnscan -d $domain -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -t 32 -o $dns_path/dnscan.txt
	
	echo -e "${RED} [+] Running Fierce...... ${RESET}"	
	fierce --domain $domain --tcp | tee $dns_path/fierce.txt | tee $subdomain_path/found.txt
	
	
	#Subdomains
	echo -e "${RED} [+] Searching for Subdomains...... ${RESET}"
	echo -e "${RED} [+] Running Subfinder...... ${RESET}"
	subfinder -d $domain -nW -o $subdomain_path/subfinder.txt | tee -a $subdomain_path/found.txt
	
	echo -e "${RED} [+] Running Sublist3r...... ${RESET}"
	sublist3r -d $domain | tee $subdomain_path/sublist3r.txt | tee -a $subdomain_path/found.txt
	
	echo -e "${RED} [+] Running Assetfinder...... ${RESET}"
	assetfinder -subs-only $domain | grep $domain | tee $subdomain_path/assetfinder.txt | tee -a $subdomain_path/found.txt
	
	echo -e "${RED} [+] Sorting results..... ${RESET}"
	cat $subdomain_path/found.txt | grep $domain | sort -u > $subdomain_path/sorted.txt
	
	#Amass may be intrusive.  NOT OSINT
	#echo -e "${RED} [+] Running Amass. This could take a while...... ${RESET}"
	#amass enum -d $domain | tee $subdomain_path/amass.txt	
	
	#People
	echo -e "${RED} [+] Searching for People...... ${RESET}"
	echo -e "${RED} [+] Running theHarvester...... ${RESET}"
	theHarvester -d $domain -l 500 -b bing,baidu,duckduckgo,certspotter,crtsh,yahoo -f $people_path/harvester | tee $people_path/harvester.txt
	#Command below has an issue with the source (-b) portion.  Hopefully they fix it & reenable google & linkedIn.  :(
#	theHarvester -d $domain -l 500 -b google,bing,baidnscan -d $domain -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -t 32 du,duckduckgo,linkedin,certspotter,crtsh,yahoo -f $people_path/harvester | tee $people_path/harvester.txt
	
	mv $domain.xml $domain.json $people_path
	
	echo -e "${RED} [+] Searching for emails...... ${RESET}"
	emailfinder -d $domain | tee $people_path/emails.txt

	echo -e "${RED} [+] Sorting data..... ${RESET}"
#fi

	#Everything below this line is new
	
	echo -e "${RED} [+] Sorting data..... ${RESET}"
		
	#sorts out IP addresses and hostnames
	touch $dns_path/sorted.txt
	cat $dns_path/dnscan.txt | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -v dns | grep -v v=spf1 | grep -v 192.168.2.1 | sed 's/$/,/g' | awk '{print $3 $1}' > $dns_path/sorted.txt
	wc -l $dns_path/sorted.txt
	cat $dns_path/fierce.txt | grep $domain | sed 's/(//g' | sed 's/)//g' | sed 's/ /,/g' | cut -d , -f2,3 | sed 's/.,/,/g' >> $dns_path/sorted.txt
	wc -l $dns_path/sorted.txt
	

	#sorts sorted.txt into results.csv. First column has subdomain, second column has all IP addresses
	declare -A subdomain_array
	#echo "Subdomain,IP addresses" > $dns_path/results.csv
	while IFS=, read -r subdomain ip; do
	  if [ -z "${subdomain_array[$subdomain]}" ]; then
	    # If not, add it to the array
	    subdomain_array[$subdomain]=$ip
  	  else
  	  # If it does exist, check if the IP address is already in the list
	    if ! echo "${subdomain_array[$subdomain]}" | grep -qw "$ip"; then
    	  # If not, append the IP address to the existing value separated by a space
 	     subdomain_array[$subdomain]="${subdomain_array[$subdomain]} $ip"
   	  fi
   	fi
	done < $dns_path/sorted.txt
	
	echo "" > $dns_path/results.csv
	# Write the results to the results.csv file
	for subdomain in "${!subdomain_array[@]}"; do
	  echo "$subdomain,${subdomain_array[$subdomain]}" >> $dns_path/results.csv
	done
	echo "" > $dns_path/final.csv
	echo "Subdomain,IP addresses" > $dns_path/final.csv
	cat $dns_path/results.csv | sort >> $dns_path/final.csv

fi
	
	
	
