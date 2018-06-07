#!/bin/bash
# Install MDSplus on CentOS7, configured for use at MIT PSFC
#
# F.Sciortino 5/3/2018
# from original Ubuntu setup script for Red Pitayas by T. Golfinopoulos

echo -n "Enter your C-Mod username: "
read USERNM

#Install MDSplus source
yum -y install http://www.mdsplus.org/dist/rhel7/stable/RPMS/noarch/mdsplus-repo-7.7-13.el7.noarch.rpm

# Install all MDSplus packages
yum -y install mdsplus

# Disable MDSplus repository (prevent uncontrolled updates)
yum-config-manager --disable mdsplus

# Install MDSplus signing key
wget http://www.mdsplus.org/dist/mdsplus.gpg.key
rpm --import mdsplus.gpg.key

# Copy C-Mod environment variable setup scripts
rsync -avz $USERNM@cmodws100.psfc.mit.edu:/usr/local/mdsplus/local /usr/local/mdsplus

# Append C-Mod data servers to /etc/hosts so that hostnames are resolved to correct IP addresses
echo "# Added $(date) from mdsplus_setup.sh" >> /etc/hosts
echo "198.125.180.202 alcdata-test" >> /etc/hosts
echo "198.125.180.202 alcdata-new" >> /etc/hosts
echo "198.125.180.202 alcdata" >> /etc/hosts
echo "198.125.180.202 alcdata-saved" >> /etc/hosts
echo "198.125.180.202 alcdata-models" >> /etc/hosts
echo "198.125.177.171 alcdata-archives" >> /etc/hosts

#This is necessary to configure C-Mod environment variables
rsync -avz $USERNM@cmodws107:/usr/local/mdsplus/local /usr/local/mdsplus

#Add mdsplus-local folder
mkdir /usr/local/cmod
rsync -avz $USERNM@cmodws107:/usr/local/cmod/mdsplus-local /usr/local/cmod
rsync -avz $USERNM@cmodws107:/usr/local/cmod/sbin /usr/local/cmod

source /etc/profile
