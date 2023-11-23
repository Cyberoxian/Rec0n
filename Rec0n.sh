#!/bin/bash

    printf "\n"
    printf "\e[1m\e[31m%s\e[0m\n" "            _"
    printf "\e[1m\e[32m%s\e[0m\n" "            / \\      _-'"
    printf "\e[1m\e[33m%s\e[0m\n" "          _/|  \\-''- _ /"
    printf "\e[1m\e[34m%s\e[0m\n" "       __-' { |          \\"
    printf "\e[1m\e[35m%s\e[0m\n" "          /             \\"
    printf "\e[1m\e[36m%s\e[0m\n" "         /       \"o.  |o }"
    printf "\e[1m\e[37m%s\e[0m\n" "         |            \\ ;"
    printf "\e[1m\e[91m%s\e[0m\n" "                       ',"
    printf "\e[1m\e[92m%s\e[0m\n" "            \\_         __\\"
    printf "\e[1m\e[93m%s\e[0m\n" "              ''-_    \\.//"
    printf "\e[1m\e[94m%s\e[0m\n" "                / '-____'"
    printf "\e[1m\e[95m%s\e[0m\n" "               /"
    printf "\e[1m\e[96m%s\e[0m\n" "             _'"
    printf "\e[1m\e[97m%s\e[0m\n" "           _-'"
    printf "\e[1m\e[31m%s\e[0m\n" "			~Rajiv Sharma-0x13 (v.2)"
    printf "\n"
    printf "\n"
	
start_time=$(date +%s)

url=$1
if [ ! -d "$url" ];then
	mkdir $url
fi
if [ ! -d "$url/recon" ];then
	mkdir $url/recon
fi
if [ ! -d "$url/recon/scans" ];then
	mkdir $url/recon/scans
fi
if [ ! -d "$url/recon" ];then
	mkdir $url/recon/screenshot
fi
if [ ! -d "$url/recon" ];then
	mkdir $url/recon
fi
if [ ! -f "$url/recon/alive.txt" ];then
	touch $url/recon/alive.txt
fi
if [ ! -f "$url/recon/subdomain.txt" ];then
	touch $url/recon/subdomain.txt
fi
## Crt.sh
echo -e "\e[31m[+]\e[0m \e[33mHarvesting subdomains with crt.sh...\e[0m" #Crt.sh

requestsearch="$(curl -s "https://crt.sh?q=%.$url&output=json")"
echo $requestsearch > req.txt
cat req.txt | jq ".[].common_name,.[].name_value"| cut -d'"' -f2 | sed 's/\\n/\n/g' | sed 's/\*.//g'| sed -r 's/([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4})//g' | sort | uniq > $url/recon/crt.txt
rm req.txt
echo ""
cat $url/recon/crt.txt
echo ""
cat $url/recon/crt.txt | grep $1 >> $url/recon/subdomain.txt
echo -e "\e[32m[+]\e[0m Crt.sh Discovered \e[31m"$(cat $url/recon/crt.txt | wc -l)"\e[0m subdomains"
rm $url/recon/crt.txt

## Assetfinder
echo -e "\n\e[31m[+]\e[0m \e[33mHarvesting subdomains with assetfinder...\e[0m" #Assetfinder

assetfinder $url >> $url/recon/assets.txt
cat $url/recon/assets.txt | grep $1 >> $url/recon/subdomain.txt
echo -e "\n\e[32m[+]\e[0m Assetfinder Discovered \e[31m"$(cat $url/recon/assets.txt | wc -l)"\e[0m subdomains"
rm $url/recon/assets.txt

## Subfinder
echo -e "\n\e[31m[+]\e[0m \e[33mDouble checking for subdomains with Subfinder...\e[0m"

subfinder -d $url -all -cs | tee -a $url/recon/f.txt
cat $url/recon/f.txt | grep $1 >> $url/recon/subdomain.txt
echo -e "\e[32m[+]\e[0m Subfinder Discovered \e[31m"$(cat $url/recon/f.txt | wc -l)"\e[0m subdomains"
rm $url/recon/f.txt
echo -e "\e[32m[+]\e[0m Total Number of Subdomain's Discovered \e[31m"$(cat $url/recon/subdomain.txt | wc -l)"\e[0m from $url"

## HTTProbe
echo -e "\n\e[31m[+]\e[0m \e[33m Probing for alive domains...\e[0m" ## Install Manually by using pimpmykali tool(For Kali Linux)

cat $url/recon/subdomain.txt | sort | uniq | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >> $url/recon/a.txt
sort -u $url/recon/a.txt > $url/recon/alive.txt

echo -e "\e[32m[+]\e[0m Total Number of Alive domain's Discovered \e[31m"$(cat $url/recon/alive.txt | wc -l)"\e[0m from $url"
rm $url/recon/a.txt

## Host IPv4/IPv6
echo -e "\n\e[31m[+]\e[0m \e[33m Host with IPv4/IPv6...\e[0m"
cat "$url/recon/alive.txt" | xargs -I{} host {} | tee -a "$url/recon/host.txt"
echo -e "\n\e[32m[+]\e[0m Host Discovered \e[31m"$(cat $url/recon/host.txt | wc -l)"\e[0m IPv4/IPv6"

## HTTPX-Toolkit

echo -e "\n\e[31m[+]\e[0m \e[33m Checking Status Code of Alive Domains...\e[0m"
cat $url/recon/alive.txt | httpx-toolkit -sc >> $url/recon/status.txt
cat $url/recon/status.txt |grep "200" >> $url/recon/200.txt
cat $url/recon/status.txt |grep "403" >> $url/recon/403.txt
cat $url/recon/status.txt |grep "404" >> $url/recon/404.txt
#tr used to remove content
#sed used to remove last 3 characters
#If error occur replace [[32m200[0m] into 200 and remove sed
#If error occur replace [[31m403[0m] into 403 and remove sed
cat $url/recon/200.txt | tr -d '[[32200[0]'| sed 's/.\{3\}$//' >> $url/recon/200_live.txt 
cat $url/recon/403.txt | tr -d '[[31403[0]'| sed 's/.\{3\}$//' >> $url/recon/403_live.txt 
rm $url/recon/200.txt
rm $url/recon/403.txt
rm $url/recon/404.txt
rm $url/recon/status.txt

## Aquatone
echo -e "\n\e[31m[+]\e[0m \e[33m Scanning for Aquatone...\e[0m"
curl -s https://crt.sh/\?q\=%25.$url\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | httprobe -c  100 | aquatone -out $url/recon/screenshot

#HTTPX-Toolkit

echo -e "\n\e[31m[+]\e[0m \e[33m Checking Status Code on Terminal...\e[0m"
cat $url/recon/alive.txt | httpx-toolkit -title -wc -sc -cl -ct -cname -web-server -threads 75 -location


## Scanning Port
echo -e "\e[31m[+]\e[0m \e[33m Scanning for open ports...\e[0m"
nmap -A -iL $url/recon/alive.txt -T4 -oA $url/recon/scans/scanned.txt 


end_time=$(date +%s)
execution_time=$((end_time - start_time))

# Display completion message and execution time
printf "\n\e[1m\e[32m%s\e[0m\n" "Recon Completed Successfully!"
printf "\e[1m\e[32m%s\e[0m\n" "Total execution time: $execution_time seconds"
