#!/bin/bash
export MODULE_PREFIX="$HOME/Installed_Package"

# echo "Updating all packages"
# sudo apt update
# sudo apt --yes upgrade
# sudo apt install --yes sshfs tcl tk tcl-dev tk-dev build-essential wget cmake libboost-all-dev libprotoc-dev libprotoc-dev protobuf-compiler rsync
# echo "Completed"

# echo "Downloading Anaconda 3 Edition 2021-05"
# wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
# chmod +x Anaconda3-2021.05-Linux-x86_64.sh
# ./Anaconda3-2021.05-Linux-x86_64.sh -b -p $MODULE_PREFIX/anaconda3
# rm -rf Anaconda3-2021.05-Linux-x86_64.sh
# echo "Completed"

# echo "Downloading Environment Module"
# wget https://github.com/cea-hpc/modules/archive/refs/tags/v4.7.1.tar.gz
# tar -xvf v4.7.1.tar.gz
# cd modules-4.7.1
# ./configure --prefix=$MODULE_PREFIX/environment_modules --modulefilesdir=$MODULE_PREFIX/modules
# make -j 20 && make install
# cd ..
# rm -rf v4.7.1.tar.gz modules-4.7.1 $MODULE_PREFIX/modules
cd $MODULE_PREFIX
# echo "Completed"

echo "Downloading all required modules"
git clone --recursive https://github.com/animesh-server-dot-files/modules.git
. $MODULE_PREFIX/environment_modules/init/bash
export MODULE_PREFIX="$HOME/Installed_Package"
echo "Completed"

echo "Downloading and Building required go packages"
module load go/1.16.4
go get -u -ldflags="-s -w" github.com/gokcehan/lf
go get github.com/cov-ert/gofasta
echo "Completed"
