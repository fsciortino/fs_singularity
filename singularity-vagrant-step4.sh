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
 export LD_LIBRARY_PATH=/codes_repo/MultiNest/lib/:$LD_LIBRARY_PATH
 export PYTHONPATH=/codes_repo:/codes_repo/MITIM:/codes_repo/eqtools:/codes_repo/TRIPPy:/codes_repo/PyMultiNest:/codes_repo/profiletools:/home/sciortino:$PYTHONPATH
 # source /etc/profile at startup
 source /etc/profile
 

%setup
 echo "Working dir is" $PWD
 # ensure that /etc/profile is sourced upon opening image
 mkdir -p $SINGULARITY_ROOTS/.singularity.d/env
 echo "source /etc/profile" >> $SINGULARITY_ROOTFS/.singularity.d/env/80-custom.sh
 echo "alias h='cd /home/sciortino'" >> $SINGULARITY_ROOTFS/.singularity.d/env/80-custom.sh
 echo "module purge" >> $SINGULARITY_ROOTFS/.singularity.d/env/80-custom.sh
 echo "source /codes_repo/fs_env/bin/activate" >> $SINGULARITY_ROOTFS/.singularity.d/env/80-custom.sh

 echo "echo '80-custum.sh script was sourced'"
 chmod u+x $SINGULARITY_ROOTFS/.singularity.d/env/80-custom.sh


 
%files
 /home/sciortino/fs_singularity/mdsplus_centos7.sh /tmp/mdsplus_centos7.sh


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
 yum -y install mlocate
 yum -y install curl file git 

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
 yum -y install emacs 
 #yum-builddep -y python-matplotlib
 #yum -y install python-matplotlib # gets python2.7 version
 yum -y install python-nlopt
 # yum -y install flex

# Python pip installations (MITIM compatibility)
 pip install --upgrade pip
 pip install numpy==1.10.4
 pip install scipy==0.17.0
 pip install periodictable
 pip install emcee==2.1.0
 pip install sobol==0.9
 pip install -U setuptools wheel
 pip install 'ipython[all]==4.1.1'
 pip install scikit-image==0.12.3
 pip install pymysql
 pip install numdifftools==0.9.16
 python -mpip install -U matplotlib

# ----------- OpenMPI installation ------------

 # Save repos to a specific directory (accessible without root permissions)
 mkdir /codes_repo
 cd /codes_repo

 #echo "OpenMPI (from yum)"
 #yum -y install openmpi openmpi-devel
 #echo "Installed OpenMPI. Now mpi4py..."
 #pip install mpi4py

 #echo "Installing OpenMPI 2.1.0"
 #wget https://www.open-mpi.org/software/ompi/v2.1/downloads/openmpi-2.1.0.tar.bz2
 #tar jtf openmpi-2.1.0.tar.bz2
 #cd openmpi-2.1.0
 #./configure --prefix=/usr/local
 #make
 #make install

#----------------------

 
 echo "Installing OpenMPI from git Master into container..."
yum -y install openmpi-devel
 git clone https://github.com/open-mpi/ompi.git
 cd ompi
 ./autogen.pl
 ./configure --prefix=/usr/local/openmpi
 make
 make install
 
 export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:/usr/local/openmpi/lib
 export PATH=${PATH}:/usr/local/openmpi/lib

 ## Make module command available
 source /etc/profile
 yum -y install environment-modules
 source /etc/profile
 
 module list
 echo " "
 module avail

 #module add mpi/openmpi-x86_64
 #echo "mpirun location: " 
# which mpirun

 export PATH=${PATH}:/usr/local/openmpi/bin/mpicc
 echo "Installed OpenMPI. Now clone and install mpi4py..."
 #git clone https://github.com/mpi4py/mpi4py.git ./mpi4py.git
 #cd mpi4py.git
 #python setup.py build --mpicc=/usr/local/openmpi/bin/mpicc
 #python setup.py install
 env MPICC=/usr/local/openmpi/bin/mpicc pip install mpi4py

# -----------------------

 # Build the OpenMPI ring example and place the binary in this directory
 # mpicc examples/ring_c.c -o ring
 # Install the MPI binary into the container at /usr/bin/ring
 # cp ./ring /usr/bin/
 # Run the MPI program within the container by calling the MPIRUN on the host
 # mpirun -np 20 singularity exec /tmp/Centos-7.img /usr/bin/ring

# -----------------------

 

 ## Exclude openib from OpenMPI BTL component search
 ## Ref: www.olmjo.com/blog/2012/09/30/openmpi-warning
 # OMPI_MCA_mpi_show_handle_leaks=1
 # export OMPI_MCA_mpi_show_handle_leaks


# -------------------------
 cd /codes_repo

echo "Installing MultiNest"
 git clone https://github.com/JohannesBuchner/MultiNest.git
 cd MultiNest/build
 cmake ..
 make
 make install
 cd /codes_repo
 export LD_LIBRARY_PATH=/codes_repo/MultiNest/lib/:$LD_LIBRARY_PATH #also exported in environment section


echo "Installing PyMultiNest"
 git clone https://github.com/JohannesBuchner/PyMultiNest.git
 cd PyMultiNest
 python setup.py install
 cd /codes_repo 


echo "Obtaining gptools and profiletools"
 pip install Cython==0.23.4
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
 


# eqtools only works with numpy==1.10.4. Use virtual environment
echo "Installing virtualenv with numpy==1.10.4"
 pip install virtualenv
 virtualenv --system-site-packages fs_env
 source fs_env/bin/activate
 pip install --ignore-installed numpy==1.10.4
 # use eqtools fork by M.Churchill, which accounts for updated MDSplus exceptions
 git clone https://github.com/rmchurch/eqtools.git
 cd eqtools
 python setup.py install 
 # pip install eqtools
 # delete components of eqtools that can give warnings and are not used anyway
 rm -
 deactivate
 cd /codes_repo

%labels
 Maintainer  F.Sciortino
 Version v1.3
 email: sciortino@psfc.mit.edu
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
sudo /usr/local/bin/singularity build mitim_centos7ro.img mitim_centos7rw.img
