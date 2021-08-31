#!/bin/bash
set -e
export MODULE_PREFIX="$HOME/Installed_Package"
mkdir -p logs

RED=$(tput setaf 1)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)

center() {
	termwidth="$(tput cols)"
	padding="$(printf '%0.1s' ={1..500})"
	printf '%*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#1})/2))" "$padding" "$1" 0 "$(((termwidth-1-${#1})/2))" "$padding"
}

if [[ ! -f "$HOME/install-scripts/logs/anaconda" ]]; then
	center "${GREEN}Downloading Anaconda 3 Edition 2021-05${NORMAL}"
		rm -rf Anaconda3-2021.05-Linux-x86_64.sh
		wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
		chmod +x Anaconda3-2021.05-Linux-x86_64.sh
		./Anaconda3-2021.05-Linux-x86_64.sh -b -p $MODULE_PREFIX/anaconda3
		touch $HOME/install-scripts/logs/anaconda
		# rm -rf Anaconda3-2021.05-Linux-x86_64.sh
	center "${GREEN}Completed${NORMAL}"
fi

if [[ ! -f "$HOME/install-scripts/logs/modules" ]]; then
	center "${GREEN}Downloading Environment Module${NORMAL}"
		wget https://github.com/cea-hpc/modules/archive/refs/tags/v4.7.1.tar.gz
		tar -xvf v4.7.1.tar.gz
		cd modules-4.7.1
		./configure --prefix=$MODULE_PREFIX/environment_modules --modulefilesdir=$MODULE_PREFIX/modules
		make -j 20 && make install
		touch $HOME/install-scripts/logs/modules
		cd $MODULE_PREFIX
		# rm -rf v4.7.1.tar.gz modules-4.7.1 $MODULE_PREFIX/modules
	center "${GREEN}Completed${NORMAL}"
fi

# echo "Downloading all required modules"
# 	git clone --recursive https://github.com/animesh-server-dot-files/modules.git modules_source
# 	mkdir -p modules/python
# 	mkdir -p modules/golang
# 	mkdir -p modules/nextstrain
# 	mkdir -p modules/usher
# 	mkdir -p modules/anaconda
# 	mkdir -p modules/bwa
# 	mkdir -p modules/fastqc
# 	mkdir -p modules/gatk
# 	mkdir -p modules/picard
# 	mkdir -p modules/rclone
# 	mkdir -p modules/samtools
# 	mkdir -p modules/seqtk
# 	ln modules_source/usher/0.3 modules/usher/0.3
# 	ln modules_source/python/3.9.5 modules/python/3.9.5
# 	ln modules_source/python/2.7.18 modules/python/2.7.18
# 	ln modules_source/golang/1.16.4 modules/golang/1.16.4
# 	ln modules_source/anaconda/3-2021.05 modules/anaconda/3-2021.05
# 	ln modules_source/nextstrain/1.0.0_a9 modules/nextstrain/1.0.0_a9
# 	. $MODULE_PREFIX/environment_modules/init/bash
# echo "Completed"

# echo "Building BWA"
# 	cd $MODULE_PREFIX/modules_source/bwa/v0.7.17/
# 	mkdir -p package
# 	cd source
# 	make -j 10
# 	mv bwa bwa.1 ../package/
# echo "Completed"

# echo "Building Seqtk"
# 	cd $MODULE_PREFIX/modules_source/seqtk/v1.3/
# 	mkdir -p package
# 	cd source
# 	make -j 10
# 	mv seqtk ../package/
# echo "Completed"

# echo "Building Samtools"
# 	cd $MODULE_PREFIX/modules_source/samtools/v1.13/source
# 	./configure --prefix $MODULE_PREFIX/modules_source/samtools/v1.13/package
# 	make -j 10 && make install
# 	make clean
# echo "Completed"

# echo "Configuring Anaconda and Installing required packages"
# 	module load anaconda/3-2021.05
# 	conda create --yes -n python_3.9 python=3.9
# 	conda create --yes -n python_2.7 python=2.7
# 	conda config --add channels conda-forge
# 	conda config --add channels bioconda
# 	conda activate python_3.9
# 	conda install --yes mafft iqtree minimap2 cmake protobuf gcc_linux-64 git
# 	conda deactivate
# 	module unload anaconda/3-2021.05
# echo "Completed"

# echo "Downloading and Building required go packages"
# 	module load golang/1.16.4
# 	go get -u -ldflags="-s -w" github.com/gokcehan/lf
# 	go get github.com/cov-ert/gofasta
# echo "Completed"

# echo "Appending lines to bashrc"
# echo 'export MODULE_PREFIX="$HOME/Installed_Package"' >> ~/.bash_profile
# echo '. $MODULE_PREFIX/environment_modules/init/bash' >> ~/.bash_profile
# echo "module load python/3.9.5 golang/1.16.4" >> $MODULE_PREFIX/environment_modules/init/modulerc
# echo "Completed"

# echo "Building UShER"
# cd modules/usher/v0.3/source
# mkdir -p usher_build && cd usher_build
# cmake -DTBB_DIR=${PWD}/../oneTBB-2019_U9  -DCMAKE_PREFIX_PATH=${PWD}/../oneTBB-2019_U9/cmake ..
# make -j 20
# mkdir -p ../../package
# cp parsimony.pb.h parsimony.pb.cc matOptimize usher matUtils ../../package/
# cd ../..
# rm -rf source/usher_build source/oneTBB-2019_U9/cmake/TBBConfig.cmake source/oneTBB-2019_U9/cmake/TBBConfigVersion.cmake
# echo "Completed"

# echo "Installing required python packages"
# module load python/3.9.5
# pip install nextstrain-augur snakemake==6.3.0 tqdm bpytop cython fuzzyset arrow pendulum biopython pytools openpyxl
# pip install git+https://github.com/cov-lineages/pangolin.git 
# pip install git+https://github.com/cov-lineages/pangoLEARN.git 
# pip install git+https://github.com/cov-lineages/scorpio.git 
# pip install git+https://github.com/cov-lineages/constellations.git
# echo "Completed"
