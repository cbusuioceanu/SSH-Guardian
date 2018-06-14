#!/bin/bash

#HOME=/root
#LOGNAME=root
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#LANG=en_US.UTF-8
#SHELL=/bin/sh
#PWD=/root

# Don't forget to write the CRON_JOB in /var/spool/cron/root
#  * * * * * /usr/bin/bash /root/sshguardian.sh # cron job every minute to make sure the script is up and running
# Warning: failure to enter your Local IP or your Public IP
# in the allowed_hosts, you will get blocked!!!

##############################
# * Constantin Busuioceanu * #
# * Developed in 2017      * #
##############################

### VARS
logfile="/var/log/sshguardian.log"
### EMAIL SENDING VARS
emailsrvname="/.mailserver"
emailsrvdetails="$emailsrvname"
getfromname=$(cat $emailsrvdetails 2> /dev/null | grep fromname | cut -d "'" -f2)
gettoname=$(cat $emailsrvdetails 2> /dev/null | grep toname | cut -d "'" -f2)
getsmtpserver=$(cat $emailsrvdetails 2> /dev/null | grep smtpserver | cut -d "'" -f2)
getsmtpuser=$(cat $emailsrvdetails 2> /dev/null | grep smtpuser | cut -d "'" -f2)
getsmtppwd=$(cat $emailsrvdetails 2> /dev/null | grep smtppwd | cut -d "'" -f2)
###

### CHANGE THESE VARS WITH YOUR VALUES
allowed_host_1="local_or_public_ip1"
allowed_host_2="local_or_public_ip2"
allowed_host_3="local_or_public_ip3"
allowed_host_4="local_or_public_ip4"
sshport=":2666"
###

###
if [[ ! -e $emailsrvdetails ]]; then

echo -e "\\nNo mailing.server details found..."
echo "Running first time configuration..."

echo "
+---------------------------+
|e.g. smtp.gmail.com:587    |
|Port for TLS/STARTTLS: 587 |
|Port for SSL: 465          |
|Username: name@domain.tld  |
+---------------------------+
"

read -e -p "FROM NAME (eg: abc@xyz.com (Server Security)): " fromname
read -e -p "TO ADDRESS (where you will receive notifications): " toname
read -e -p "SMTP SERVER: " smtpserver
read -e -p "SMTP USER: " smtpuser
read -e -p "SMTP PASS: " smtppass


echo " Saving entered details: $fromname | $smtpserver | $smtpuser | $smtppass"
echo "fromname='$fromname'
toname='$toname'
smtpserver='$smtpserver'
smtpuser='$smtpuser'
smtppwd='$smtppass'" > $emailsrvdetails

echo "mailing.server details saved @ $emailsrvdetails"

else
	if [[ -e $emailsrvdetails ]];
	then
		echo -e "\\nmailing.server details found..." > /dev/null
		echo "No need to write them again..." > /dev/null
		echo -e "Using details located @ $emailsrvdetails" > /dev/null
	fi
fi
###

###
if [[ $(ps aux | grep cron- | grep -v grep | awk '{print $2}' | wc -l) == 0 ]]; then

echo "Starting script..."
else
	if [[ ! $(ps aux | grep cron- | grep -v grep | awk '{print $2}' | wc -l) == 2 ]]; then
		echo "Script already running!" > /dev/null
		exit 0
	fi
fi
###

while true; do

if [[ -e "$logfile" ]]; then

        echo "LOG file found @ $logfile" > /dev/null
else
        echo "LOG file not found @ $logfile"
        echo "Creating one..."
        touch "$logfile"
fi

findintruder=$(netstat -tanp | grep ESTABLISHED | grep "$sshport" | awk '{print $5"-"$7}' > /tmp/ssh_ips)
findintruder_tmp="/tmp/ssh_ips"
catintruder_tmp=$(cat "$findintruder_tmp")

	for i in $findintruder_tmp;
	do
		for ii in $catintruder_tmp;
		do
			getintruderip=$(grep $ii $i | awk 'NR==1{print $1}' | cut -d ':' -f1)
			getintruderport=$(grep $ii $i | awk 'NR==1{print $1}' | cut -d '-' -f1 | cut -d':' -f2)
			getintrudersshps=$(grep $ii $i | grep - | cut -d '-' -f2 | cut -d '/' -f1)

			if [[ $getintruderip == $allowed_host_1 || $getintruderip == $allowed_host_2 || $getintruderip == $allowed_host_3 || $getintruderip == $allowed_host_4 ]]; then # if IP is allowed, log only time and date when connected

echo -e "$(date) \
IP=$(if [[ $getintruderip == "" ]];then echo "No IP connected to SSH |" >> $logfile; else if [[ $getintruderip == * ]];then echo "$getintruderip"; fi fi) \
from PORT=$(if [[ $getintruderport == "" ]];then echo "No PORT connected to SSH |"; else if [[ $getintruderport == * ]];then echo "$getintruderport"; fi fi) \
using SSHD_PROCESS=$(if [[ $getintrudersshps == "" ]];then echo "No SSHD_PROCESS in use"; else if [[ $getintrudersshps == * ]];then echo "$getintrudersshps"; fi fi)" >> $logfile

			else
				if [[ ! $getintruderip == $allowed_host_1 || $getintruderip == $allowed_host_2 || $getintruderip == $allowed_host_3 || $getintruderip == $allowed_host_4 ]]; then # block IP if variables are false (see [[ ! ]])

echo -e "$(date) \
INTRUDER_ALERT IP=$(if [[ "$getintruderip" == "" ]];then echo "No IP connected to SSH |"; else if [[ "$getintruderip" == * ]];then echo "$getintruderip"; fi fi) \
from PORT=$(if [[ "$getintruderport" == "" ]];then echo "No PORT connected to SSH |"; else if [[ "$getintruderport" == * ]];then echo "$getintruderport"; fi fi) \
using SSHD_PROCESS=$(if [[ "$getintrudersshps" == "" ]];then echo "No SSHD_PROCESS in use"; else if [[ "$getintrudersshps" == * ]];then echo "$getintrudersshps | INTRUDER_IP=$getintruderip will be blocked!"; fi fi)" >> $logfile


					if [[ $(iptables -L INPUT | grep $getintruderip | awk 'NR==1{print $4}') == $getintruderip ]]; then
						echo "IP=$getintruderip is already blocked. Email report sending aborted."
						kill -9 $getintrudersshps # kill that SHH_PROCESS
					else
						if [[ ! $(iptables -L INPUT | grep $getintruderip | awk 'NR==1{print $4}') == $getintruderip ]]; then
							echo "IP=$getintruderip will be blocked."

							iptables -I INPUT -s $getintruderip -j DROP
							iptables -I OUTPUT -d $getintruderip -j DROP
							iptables -I DENYIN -s $getintruderip -j DROP
							iptables -I DENYOUT -d $getintruderip -j DROP

							kill -9 $getintrudersshps # kill that SHH_PROCESS

echo -e "INTRUDER_ALERT ON $HOSTNAME\\n\\n Showing last 10 lines from $logfile\\n\\n \
$(tail -n 10 $logfile) \\n\\n \
INPUT: $(iptables -L INPUT -n | grep $getintruderip) \\n\\n \
OUTPUT: $(iptables -L OUTPUT -n | grep $getintruderip) \\n\\n \
DENYIN: $(iptables -L DENYIN -n | grep $getintruderip) \\n\\n \
DENYOUT: $(iptables -L DENYOUT -n | grep $getintruderip)" | mailx -v \
-r "$getfromname" \
-s "INTRUDER_ALERT ON $HOSTNAME" \
-S smtp="$getsmtpserver" \
-S smtp-use-starttls \
-S smtp-auth=login \
-S smtp-auth-user="$getsmtpuser" \
-S smtp-auth-password="$getsmtppwd" \
-S nss-config-dir=/etc/pki/nssdb \
-S ssl-verify=ignore \
"$gettoname"

						fi
					fi
				fi # block IP if variables are false (see [[ ! ]])
			fi # if IP is allowed, log only time and date when connected
		continue
		done # catintruder_tmp for end
	break
	done # findintruder_tmp for end
sleep 0.6
done
