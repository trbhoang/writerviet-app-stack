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


# # remove amazon-ssm-agent
# snap remove amazon-ssm-agent

# # remove never-used services: snapd,...
# # ref: https://peteris.rocks/blog/htop/

sudo apt-get remove snapd -y --purge
sudo apt-get remove mdadm -y --purge
sudo apt-get remove policykit-1 -y --purge
sudo apt-get remove open-iscsi -y --purge
sudo systemctl stop getty@tty1

# remove git
sudo apt-get remove git -y --purge
sudo apt-get remove tmux -y --purge
sudo apt-get remove telnet -y --purge
sudo apt-get remove git-man -y --purge

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
timedatectl set-timezone $TIMEZONE


# Change hostname
hostnamectl set-hostname $HOST_NAME
sed -i "1i 127.0.1.1 $HOST_DNS $HOST_NAME" /etc/hosts


# Disable ipv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
sudo sysctl -p


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
echo "PasswordAuthentication no" | tee --append /etc/ssh/sshd_config
echo "PermitEmptyPasswords no" | tee --append /etc/ssh/sshd_config
echo "PermitRootLogin no" | tee --append /etc/ssh/sshd_config

echo "Protocol 2" | tee --append /etc/ssh/sshd_config
# Have only 1m to successfully login
echo "LoginGraceTime 1m" | tee --append /etc/ssh/sshd_config

if [ $APP_ENV == 'production' ]
then
    # Only allow specific user to login
    echo "AllowUsers $SYSADMIN_USER" | tee --append /etc/ssh/sshd_config
    # configure idle timeout interval (10 mins)
    echo "ClientAliveInterval 600" | tee --append /etc/ssh/sshd_config
    echo "ClientAliveCountMax 3" | tee --append /etc/ssh/sshd_config
fi

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


#
# Install Docker
#
sudo apt-get remove docker docker-engine docker.io
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y --no-install-recommends docker-ce

# https://www.digitalocean.com/community/questions/how-to-fix-docker-got-permission-denied-while-trying-to-connect-to-the-docker-daemon-socket
# switch to user SYSADMIN_USER ??? su $SYSADMIN_USER
sudo usermod -aG docker $USER $SYSADMIN_USER  # may need to logout and login again
# sudo su
# su $SYSADMIN_USER
docker run hello-world

# Install docker-compose
sudo wget "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -O /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# Otherwise filebeat cannot access docker's logs
sudo chmod 666 /var/run/docker.sock


#
# Install Fail2ban
#
sudo apt-get -y install fail2ban
sudo cp ./setup/fail2ban/jail.local /etc/fail2ban/jail.local
sudo systemctl restart fail2ban
