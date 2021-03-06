#!/bin/bash
#
# Step 5
# 5.1 Get rid of intermediate files, VMs and containers.

. ./setup-vagrant-parms.sh

# 1.
vagrant destroy -f
vagrant box remove -f --provider virtualbox ubuntu/trusty64


echo ' '
echo ' ################# ' 
echo "Remember to bind directories with cluster!"
echo 'singularity run --bind /home/sciortino mitim_centos7rw.img'
echo 'or'
echo 'export SINGULARITY_BINDPATH="home/sciortino/" '
echo ' '
echo 'Binded directories must be already existent within the container'
echo ' '
echo 'hasta la vista'
echo ' ################# ' 
