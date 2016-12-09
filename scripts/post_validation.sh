#!/bin/bash
printf "\n"
echo -e "\e[1;34m----------------- Service Checks -----------------\e[0m"
printf "\n"

ports=( "22" "15672" "27017" "9999" "25" "6379" "9200" "80" "8888" )
service=( "SSH" "RabbitMQ" "MongoDB" "Test Service" "HARAKA" "REDIS" "ElastciSearch" "Nginx" "Icinga" )
portlen=${#ports[@]}
servicelen=${#service[@]}

for ((i=0,j=0;i<${portlen},j<${servicelen};i++,j++))
do
if lsof -i:${ports[$i]} > /dev/null
then
    echo -e "\e[1;32m${service[$j]} is up and Listening on port ${ports[$i]}\e[0m"
else
    echo -e "\e[1;31m${service[$j]} is down or not listening on port ${ports[$i]}\e[0m"

fi
printf "\n"
done

echo -e "\e[1;34m----------------- Internet Connectivity Check -----------------\e[0m"
printf "\n"
if nc -zw2 google.com 80 > /dev/null
then
  echo -e "\e[1;32mHTTP connectivity is up\e[0m"
else
  echo -e "\e[1;31mThe network is down or very slow\e[0m"
fi

printf "\n"
echo -e "\e[1;34m----------------- SSL Cert Checks -----------------\e[0m"
printf "\n"
SSL_CERT=/root/fullcert.pem
KORE_CONFIG=/var/www/KoreServer/config/KoreConfig.json
ExpDate=`openssl x509 -enddate -noout -in $SSL_CERT | cut -d"=" -f 2`
CERT_CNAME=`openssl x509 -subject -noout -in $SSL_CERT | cut -d"=" -f 3 | sed -e 's/^[[:space:]]*//'`
CNAME_DEF=`grep hostname $KORE_CONFIG | cut -d":" -f 2 | cut -d"," -f 1 | tr -d '"' |sed -e 's/^[[:space:]]*//'`
if openssl x509 -checkend 2592000 -noout -in $SSL_CERT
then
  echo -e "Certificate is good for another month! & Valid till \e[1;32m$ExpDate\e[0m"
else
  echo -e "\e[1;31mCertificate has expired or will do so within one month! & Expires on $ExpDate\e[0m"
  echo "(or is invalid/not found)"
fi
printf "\n"
if [[ $CERT_CNAME == $CNAME_DEF ]]; then
  echo -e "CNAME configured in koreconfig (\e[1;32m$CNAME_DEF\e[0m) matches with ssl certicate cname (\e[1;32m$CERT_CNAME\e[0m)"
else
  echo -e "Hostname (\e[1;32m$CNAME_DEF\e[0m)  mismatch with ssl certicate cname (\e[1;32m$CERT_CNAME\e[0m)"
fi
printf "\n"

echo -e "\e[1;34m----------------- Koreconfig Configuration Checks -----------------\e[0m"
printf "\n"
KORE_CONFIG=/var/www/KoreServer/config/KoreConfig.json
ENCRYTION_VAL=`grep -v "^\/\/" $KORE_CONFIG | jq '.crypto.enable'`
ISSECURE_VAL=`grep -v "^\/\/" $KORE_CONFIG | jq '.botrtm.isSecure'`
#BOT_EMAIL_VAL=`grep -v "^\/\/" $KORE_CONFIG | jq '.bot_email'`
echo -e "crypto.enable is \e[1;32m"$ENCRYTION_VAL"\e[0m"
printf "\n"
echo -e "botrtm.isSecure is \e[1;32m"$ISSECURE_VAL"\e[0m"
printf "\n"
echo -e "Email config for bot_email are \e[1;32m`grep -v "^\/\/" $KORE_CONFIG | jq '.bot_email'`\e[0m"
printf "\n"
