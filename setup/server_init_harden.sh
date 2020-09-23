#!/bin/bash

#########################################################
#  Remove amazon ssm agent which might become a backdoor
#  Create sys admin user
#  Secure ssh
#  Install docker & docker-compose
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
sudo usermod -aG docker $SYSADMIN_USER  # may need to logout and login again
docker run hello-world

# Install docker-compose
sudo wget "https://github.com/docker/compose/releases/download/1.27.2/docker-compose-$(uname -s)-$(uname -m)" -O /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
