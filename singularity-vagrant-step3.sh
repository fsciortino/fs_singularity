#!/bin/bash
#
# Step 3
# 3.1 Install needed software in vagrant VM
# 3.2 Build singularity on vagrant VM

. ./setup-vagrant-parms.sh

# 1.
vagrant ssh -c "sudo apt-get -y update"
vagrant ssh -c "sudo apt-get -y install build-essential"
vagrant ssh -c "sudo apt-get -y install curl git man vim autoconf libtool squashfs-tools libarchive-dev"

# 2.
vagrant ssh -c  "git clone https://github.com/singularityware/singularity.git"
vagrant ssh -c  "cd singularity;./autogen.sh"
vagrant ssh -c  "cd singularity;./configure --prefix=/usr/local"
vagrant ssh -c  "cd singularity;make"
vagrant ssh -c  "cd singularity;sudo make install"

