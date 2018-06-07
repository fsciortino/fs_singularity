#!/bin/bash
#
# Step 4
# 4.1 Create a config file, called "Singularity", the will be used to 
#     create a container image.
# 4.2 Create a container image based on the config file.
# 4.3 Copy the writable form of the container to the host for
#     use as a container image.
# 4.4 Install MDSplus and obtain required environment variables
# 4.5 Create read-only squash-fs form of the container on the host system

. ./setup-vagrant-parms.sh

# 1.
cat <<'EOFA' > Singularity
BootStrap: docker
From: centos:latest

%runscript
 exec echo "Singularity container for the MITIM framework"

%help
 Container for the MITIM framework.

%environment
 export LC_ALL=C

%setup
 echo "Working dir is" $PWD

 # ensure that /etc/profile is sourced upon opening image
 mkdir -p $SINGULARITY_ROOTS/.singularity.d/env
 echo "source /etc/profile" >> $SINGULARITY_ROOTFS/.singularity.d/env/80-custom.sh
 chmod u+x $SINGULARITY_ROOTFS/.singularity.d/env/80-custom.sh

%files
 /home/sciortino/fs_singularity/mdsplus_centos7.sh 

%post
 yum -y update
 yum -y groupinstall 'Development Tools'
 yum -y install bind-utils
 yum -y install infiniband-diags
 yum -y install epel-release
 yum -y install vim
 yum -y install net-tools
 yum -y install nmap-ncat
 yum -y install telnet
 yum -y install wget

 # Require python 2.7
 echo "Python version: "
 python -V

 yum -y install python-devel
 yum -y install python-pip
 yum -y install yum-utils
 yum -y install tkinter
 yum -y install lapack-devel lapack blas blas-devel
 yum -y install gcc
 yum -y install cmake
 #yum-builddep python-matplotlib
 #yum -y install python-matplotlib # gets python2.7 version
 yum -y install python-nlopt

# Python pip installations (MITIM compatibility)
 pip install --upgrade pip
 pip install numpy==1.10.4
 pip install scipy==0.17.0
 pip install scikit-image
 pip install scikit-learn
 pip install scikit-neuralnetwork
 pip install periodictable
 pip install emcee==2.1.0
 pip install sobol==0.9
 pip install -U pip setuptools wheel
 pip install ipython==4.1.1
 pip install sklearn
 pip install pymysql
 pip install numdifftools==0.9.16

echo "Get OpenMPI from yum"
yum -y install openmpi openmpi-devel

# Load module command
source /etc/profile.d/modules.sh
yum install environment-modules
module add mpi/openmpi-x86_64
echo "mpirun location: " which mpirun


 #echo "Installing OpenMPI into container..."
 #yum -y install flex
 #git clone https://github.com/open-mpi/ompi.git
 #cd ompi
 #./autogen.pl
 #./configure --prefix=/usr/local
 #make
 #make install
 #cd $HOME
 #module add mpi/openmpi-x86_64

# Exclude openib from OpenMPI BTL component search
# Ref: www.olmjo.com/blog/2012/09/30/openmpi-warning
# OMPI_MCA_mpi_show_handle_leaks=1
# export OMPI_MCA_mpi_show_handle_leaks
 
 echo "Installed OpenMPI. Now mpi4py..."
 pip install mpi4py


echo "Installing MultiNest"
git clone https://github.com/JohannesBuchner/MultiNest.git
cd MultiNest/build
cmake ..
make
make install
cd $HOME
export LD_LIBRARY_PATH=/home/sciortino/MultiNest/lib/:$LD_LIBRARY_PATH


echo "Installing PyMultiNest"
git clone https://github.com/JohannesBuchner/PyMultiNest.git
cd PyMultiNest
python setup.py install
cd $HOME 


echo "Obtaining eqtools, gptools and profiletools"
# Install numpy 1.10.4 again since eqtools only works with that version
# Some other package (in the pip list) automatically changes version...
pip install numpy==1.10.4
pip install eqtools
pip install Cython
pip install gptools
# no pip installation is available for profiletools
git clone https://github.com/markchil/profiletools.git

 
echo "Get Toroidal Radiation Inversion Protocol (Python)"
git clone https://github.com/fsciortino/TRIPPy

echo "******** Get MITIM codes ******"
git clone https://github.com/fsciortino/MITIM


echo "Creating engaging-like directories"
 mkdir -p /nobackup1c/users/sciortino
 mkdir -p /home/sciortino
 HOME=/home/sciortino
 alias h='cd $HOME'

%labels
 Maintainer  F.Sciortino
 Version v1.1
 email sciortino@psfc.mit.edu
EOFA

# 2.
vagrant ssh -c "sudo /bin/rm mitim_centos7rw.img"
vagrant ssh -c "sudo /bin/rm mitim_centos7ro.img"
vagrant ssh -c "sudo /usr/local/bin/singularity image.create --size 4048 mitim_centos7rw.img"
vagrant ssh -c "sudo /usr/local/bin/singularity build --writable mitim_centos7rw.img /vagrant/Singularity"

# 3.
vagrant ssh -c "sudo cp mitim_centos7rw.img /vagrant"

# 4.
# Install MDSplus in container, adding appropriate trees
sudo singularity exec -B /home/sciortino --writable mitim_centos7rw.img /home/sciortino/fs_singularity/mdsplus_centos7.sh

# test MDSplus installation
singularity exec mitim_centos7rw.img python -c "import MDSplus; tree=MDSplus.Tree('cmod',1101014019); print 'MDSplus working well'"

# 5.
# Create read-only image
sudo singularity build mitim_centos7ro.img mitim_centos7rw.img
