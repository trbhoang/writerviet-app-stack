#!/bin/bash

#########################################################
#  Remove amazon ssm agent which might become a backdoor
#  Create sys admin user
#  Secure ssh
#  Set timezone to UTC
#  Install & configure sendmail
#  Install & configure CSF
#########################################################



# load config vars
source .env.sh


# remove amazon-ssm-agent
snap remove amazon-ssm-agent

# remove never-used services: snapd, lxcfs
# ref: https://peteris.rocks/blog/htop/
sudo apt-get remove lvm2 -y --purge
sudo apt-get remove snapd -y --purge
sudo apt-get remove lxcfs -y --purge
sudo apt-get remove mdadm -y --purge
sudo apt-get remove policykit-1 -y --purge
sudo apt-get remove open-iscsi -y --purge
sudo systemctl stop getty@tty1

# remove git, python, samba
sudo apt-get remove git -y --purge
sudo apt-get remove python -y --purge
sudo apt-get remove python3 -y --purge
sudo apt-get remove samba-common -y --purge
sudo apt-get remove tmux -y --purge
sudo apt-get remove telnet -y --purge
sudo apt-get remove git-man -y --purge
sudo apt-get remove python-apt-common -y --purge

sudo apt-get autoremove


# Fix environment
echo 'LC_ALL="en_US.UTF-8"' >> /etc/environment
echo 'LC_CTYPE="en_US.UTF-8"' >> /etc/environment


# Install essential packages
apt-get dist-upgrade ; apt-get -y update ; apt-get -y upgrade
apt-get -y --no-install-recommends install unattended-upgrades \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    gnupg \
    curl \
    htop
    # apache2-utils


# Install security updates automatically
echo -e "APT::Periodic::Update-Package-Lists \"1\";\nAPT::Periodic::Unattended-Upgrade \"1\";\nUnattended-Upgrade::Automatic-Reboot \"false\";\n" > /etc/apt/apt.conf.d/20auto-upgrades
/etc/init.d/unattended-upgrades restart


# Change the timezone
echo $TIMEZONE > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata


# Change hostname
hostnamectl set-hostname $HOST_NAME
sed -i "1i 127.0.1.1 $HOST_DNS $HOST_NAME" /etc/hosts



# Create admin user
adduser --disabled-password --gecos "Admin" $SYSADMIN_USER

# Setup admin password
echo $SYSADMIN_USER:$SYSADMIN_PASSWD | chpasswd

# Allow sudo for sys admin user
echo "$SYSADMIN_USER    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Setup SSH keys
mkdir -p /home/$SYSADMIN_USER/.ssh/
echo $KEY > /home/$SYSADMIN_USER/.ssh/authorized_keys
chmod 700 /home/$SYSADMIN_USER/.ssh/
chmod 600 /home/$SYSADMIN_USER/.ssh/authorized_keys
chown -R $SYSADMIN_USER:$SYSADMIN_USER /home/$SYSADMIN_USER/.ssh

# Disable password login for this user
# Optional
echo "PasswordAuthentication no" | tee --append /etc/ssh/sshd_config
echo "PermitEmptyPasswords no" | tee --append /etc/ssh/sshd_config
echo "PermitRootLogin no" | tee --append /etc/ssh/sshd_config
echo "Protocol 2" | tee --append /etc/ssh/sshd_config
# configure idle timeout interval
echo "ClientAliveInterval 360" | tee --append /etc/ssh/sshd_config
echo "ClientAliveCountMax 0" | tee --append /etc/ssh/sshd_config
# disable port forwarding (yes: to support connecting from localhost)
echo "AllowTcpForwarding yes" | tee --append /etc/ssh/sshd_config
echo "X11Forwarding no" | tee --append /etc/ssh/sshd_config
echo "UseDNS no" | tee --append /etc/ssh/sshd_config

# Reload SSH changes
systemctl reload sshd



# Install & configure sendmail
apt-get -y install sendmail
sed -i "/MAILER_DEFINITIONS/ a FEATURE(\`authinfo', \`hash -o /etc/mail/authinfo/smtp-auth.db\')dnl" /etc/mail/sendmail.mc
sed -i "/MAILER_DEFINITIONS/ a define(\`confAUTH_MECHANISMS', \`EXTERNAL GSSAPI DIGEST-MD5 CRAM-MD5 LOGIN PLAIN\')dnl" /etc/mail/sendmail.mc
sed -i "/MAILER_DEFINITIONS/ a TRUST_AUTH_MECH(\`EXTERNAL DIGEST-MD5 CRAM-MD5 LOGIN PLAIN')dnl" /etc/mail/sendmail.mc
sed -i "/MAILER_DEFINITIONS/ a define(\`confAUTH_OPTIONS', \`A p')dnl" /etc/mail/sendmail.mc
sed -i "/MAILER_DEFINITIONS/ a define(\`ESMTP_MAILER_ARGS', \`TCP \$h 587')dnl" /etc/mail/sendmail.mc
sed -i "/MAILER_DEFINITIONS/ a define(\`RELAY_MAILER_ARGS', \`TCP \$h 587')dnl" /etc/mail/sendmail.mc
sed -i "/MAILER_DEFINITIONS/ a define(\`SMART_HOST', \`[email-smtp.us-east-1.amazonaws.com]')dnl" /etc/mail/sendmail.mc

mkdir /etc/mail/authinfo
chmod 750 /etc/mail/authinfo
cd /etc/mail/authinfo
echo "AuthInfo: \"U:root\" \"I:$SMTP_USER\" \"P:$SMTP_PASS\"" > smtp-auth
chmod 600 smtp-auth
makemap hash smtp-auth < smtp-auth

make -C /etc/mail
systemctl restart sendmail
echo "Subject: sendmail test" | sendmail -v $SYSADMIN_EMAIL



### Firewall & login monitoring (csf, lfd)
if [ $APP_ENV == 'production' ]
then
    # Install & configure CSF (https://www.configserver.com/cp/csf.html)
    apt-get -y --no-install-recommends install libwww-perl
    cd /usr/src/
    wget https://download.configserver.com/csf.tgz
    tar -xzf csf.tgz
    cd csf
    sh install.sh
    cd /usr/local/csf/bin/
    perl csftest.pl
    # Custom some csf settings
    sed -i 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf
    sed -i 's/SMTP_BLOCK = "0"/SMTP_BLOCK = "1"/g' /etc/csf/csf.conf
    sed -i 's/PT_SKIP_HTTP = "0"/PT_SKIP_HTTP = "1"/g' /etc/csf/csf.conf
    sed -i 's/PT_USERPROC = "10"/PT_USERPROC = "15"/g' /etc/csf/csf.conf
    sed -i 's/IGNORE_ALLOW = "0"/IGNORE_ALLOW = "1"/g' /etc/csf/csf.conf
    # Disallow incomming PING
    sed -i 's/ICMP_IN = "1"/ICMP_IN = "0"/g' /etc/csf/csf.conf
    sed -i 's/LF_ALERT_TO = ""/LF_ALERT_TO = "'$SYSADMIN_EMAIL'"/g' /etc/csf/csf.conf
    # Oply allowed these TCP ports: 22, 80, 443
    sed -i 's/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995"/TCP_IN = "22,80,443"/g' /etc/csf/csf.conf
    sed -i 's/TCP_OUT = "20,21,22,25,53,80,110,113,443,587,993,995"/TCP_OUT = "22,80,443"/g' /etc/csf/csf.conf
    sed -i 's/UDP_IN = "20,21,53"/UDP_IN = ""/g' /etc/csf/csf.conf
    sed -i 's/UDP_OUT = "20,21,53,113,123"/UDP_OUT = ""/g' /etc/csf/csf.conf
    # disable LFD excessive resource usage alert
    # ref: https://www.interserver.net/tips/kb/disable-lfd-excessive-resource-usage-alert/
    sed -i 's/PT_USERMEM = "512"/PT_USERMEM = "0"/g' /etc/csf/csf.conf
    sed -i 's/PT_USERTIME = "1800"/PT_USERTIME = "0"/g' /etc/csf/csf.conf
    # Ignore alert if following process use exeeded resource
    echo "exe:/usr/sbin/rsyslogd" | tee --append /etc/csf/csf.pignore
    echo "exe:/lib/systemd/systemd-networkd" | tee --append /etc/csf/csf.pignore
    echo "exe:/usr/sbin/atd" | tee --append /etc/csf/csf.pignore
    echo "exe:/lib/systemd/systemd" | tee --append /etc/csf/csf.pignore
    echo "exe:/lib/systemd/systemd-resolved" | tee --append /etc/csf/csf.pignore
    systemctl start csf
    systemctl start lfd
    systemctl enable csf
    systemctl enable lfd
    # List csf firewall rules
    csf -l
fi


#
# Install Docker
#
sudo apt-get remove docker docker-engine docker.io
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y --no-install-recommends docker-ce
# switch to user SYSADMIN_USER ??? su $SYSADMIN_USER
sudo usermod -aG docker $USER  # may need to logout and login again
newgrp docker
docker run hello-world

# Install docker-compose
sudo wget "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -O /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
