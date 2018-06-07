#!/bin/bash
#
# Run all the steps to produce singularity-build-dir/centos7ro.img
# and clean up.
#
./singularity-vagrant-step1.sh
./singularity-vagrant-step2.sh
./singularity-vagrant-step3.sh
./singularity-vagrant-step4.sh
./singularity-vagrant-step5.sh
