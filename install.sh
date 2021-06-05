#!/bin/bash
export MODULE_PREFIX="$HOME/Installed_Package"


sudo echo -e "#Host only network\nauto enp0s8\niface enp0s8 inet static\n\t\taddress 192.168.56.105\n\t\tnetmask 255.255.255.0\n\t\tnetwork 192.168.56.0\n\t\tbroadcast 192.168.56.255" >> /etc/network/interfaces

echo "Updating all packages"
sudo apt update
sudo apt --yes upgrade
sudo apt install --yes ifupdown virtualenv sshfs tcl tk tcl-dev tk-dev build-essential wget cmake libboost-all-dev libprotoc-dev libprotoc-dev libbz2-dev protobuf-compiler rsync
echo "Completed"

echo "Downloading Anaconda 3 Edition 2021-05"
wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
chmod +x Anaconda3-2021.05-Linux-x86_64.sh
./Anaconda3-2021.05-Linux-x86_64.sh -b -p $MODULE_PREFIX/anaconda3
rm -rf Anaconda3-2021.05-Linux-x86_64.sh
echo "Completed"

echo "Downloading Environment Module"
wget https://github.com/cea-hpc/modules/archive/refs/tags/v4.7.1.tar.gz
tar -xvf v4.7.1.tar.gz
cd modules-4.7.1
./configure --prefix=$MODULE_PREFIX/environment_modules --modulefilesdir=$MODULE_PREFIX/modules
make -j 20 && make install
cd ..
rm -rf v4.7.1.tar.gz modules-4.7.1 $MODULE_PREFIX/modules
cd $MODULE_PREFIX
echo "Completed"

echo "Downloading all required modules"
git clone --recursive https://github.com/animesh-server-dot-files/modules.git
. $MODULE_PREFIX/environment_modules/init/bash
echo "Completed"

echo "Downloading and Building required go packages"
module load go/1.16.4
go get -u -ldflags="-s -w" github.com/gokcehan/lf
go get github.com/cov-ert/gofasta
echo "Completed"

echo "Building UShER"
cd modules/usher/v0.3/source
mkdir -p usher_build && cd usher_build
cmake -DTBB_DIR=${PWD}/../oneTBB-2019_U9  -DCMAKE_PREFIX_PATH=${PWD}/../oneTBB-2019_U9/cmake ..
make -j 20
mkdir -p ../../package
cp parsimony.pb.h parsimony.pb.cc matOptimize usher matUtils ../../package/
cd ../..
rm -rf source/usher_build source/oneTBB-2019_U9/cmake/TBBConfig.cmake source/oneTBB-2019_U9/cmake/TBBConfigVersion.cmake
echo "Completed"

echo "Configuring Anaconda and Installing required packages"
module load anaconda/3-2021.05
conda create --yes -n python_3.9 python=3.9
conda create --yes -n python_2.7 python=2.7
conda config --add channels conda-forge
conda config --add channels bioconda
conda activate python_3.9
conda install --yes mafft iqtree minimap2
conda deactivate
module unload anaconda/3-2021.05
echo "Completed"

echo "Installing required python packages"
module load python/3.9.5
pip install nextstrain-augur snakemake tqdm
pip install git+https://github.com/cov-lineages/pangolin.git 
pip install git+https://github.com/cov-lineages/pangoLEARN.git 
pip install git+https://github.com/cov-lineages/scorpio.git 
pip install git+https://github.com/cov-lineages/constellations.git
echo "Completed"

echo "Appending lines to bashrc"
echo 'export MODULE_PREFIX="$HOME/Installed_Package"' >> ~/.bashrc
echo '. $MODULE_PREFIX/environment_modules/init/bash' >> ~/.bashrc
echo "Completed"