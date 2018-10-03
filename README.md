# SSH Guardian [![Build Status](https://travis-ci.org/cbusuioceanu/SSH-Guardian.svg?branch=master)](https://travis-ci.org/cbusuioceanu/SSH-Guardian)
Similar to Fail2Ban but much effective in case your SSH password was compromised

#### 1. git clone https://github.com/cbusuioceanu/SSH-Guardian.git
#### 2. Mandatory: add your local IP address and public IP address to allowed_hosts. Failure to do this, you will get blocked from accessing the server!
#### 3. This script will ask you details for the Mailing Notification System. Make sure you have an account so you can use it to send Notification messages to your day to day mail.
#### 4. Before adding the CRON job, first, run the script: ```bash sshguardian.sh``` -> enter asked details about Notification email
#### 5. Create CRON job: ```sudo crontab -e``` then add ```* * * * * /usr/bin/bash /root/sshguardian.sh```
#### 6. After one minute, your script should start and run in background every 0.6 seconds. Check out logs in ```/var/log/sshguardion.sh```
#### 7. Done!

### Developed, used and tested on CentOS.
----
### LOG examples

```
Thu Jun 14 22:18:22 EEST 2018 IP=192.168.5.101 from PORT=62930 using SSHD_PROCESS=1442 -> current allowed IP running under that Pid
Thu Jun 14 22:18:22 EEST 2018 IP=192.168.5.101 from PORT=63287 using SSHD_PROCESS=48271
Thu Jun 14 22:18:22 EEST 2018 IP=192.168.5.101 from PORT=62930 using SSHD_PROCESS=1442
Thu Jun 14 22:18:22 EEST 2018 IP=192.168.5.101 from PORT=63287 using SSHD_PROCESS=48271
Thu Jun 14 22:18:23 EEST 2018 IP=192.168.5.101 from PORT=62930 using SSHD_PROCESS=1442
Thu Jun 14 22:18:23 EEST 2018 IP=192.168.5.101 from PORT=63287 using SSHD_PROCESS=48271
Thu Jun 14 22:18:24 EEST 2018 IP=192.168.5.101 from PORT=62930 using SSHD_PROCESS=1442
Thu Jun 14 22:18:24 EEST 2018 IP=192.168.5.101 from PORT=63287 using SSHD_PROCESS=48271
Thu Jun 14 22:18:24 EEST 2018 IP=192.168.5.101 from PORT=62930 using SSHD_PROCESS=1442
Thu Jun 14 22:18:24 EEST 2018 INTRUDER_ALERT IP=192.168.5.206 from PORT=54985 using SSHD_PROCESS=707 | INTRUDER_IP=192.168.5.206 will be blocked! -> Intruder IP
Thu Jun 14 22:18:24 EEST 2018 IP=192.168.5.101 from PORT=63287 using SSHD_PROCESS=48271
Thu Jun 14 22:18:25 EEST 2018 IP=192.168.5.101 from PORT=62930 using SSHD_PROCESS=1442
Thu Jun 14 22:18:25 EEST 2018 INTRUDER_ALERT IP=192.168.5.206 from PORT=54985 using SSHD_PROCESS=708 | INTRUDER_IP=192.168.5.206 will be blocked! -> Intruder IP
Thu Jun 14 22:18:25 EEST 2018 IP=192.168.5.101 from PORT=63287 using SSHD_PROCESS=48271
```
