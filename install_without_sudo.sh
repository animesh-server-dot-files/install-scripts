#!/bin/bash
set -e
export MODULE_PREFIX="$HOME/Installed_Package"
TEMP_DIR='temp'
mkdir -p logs
mkdir -p $TEMP_DIR

RED=$(tput setaf 1)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)

center() {
	termwidth="$(tput cols)"
	padding="$(printf '%0.1s' -{1..500})"
	printf '%*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#1})/2))" "$padding" "$1" 0 "$(((termwidth-1-${#1})/2))" "$padding"
}

if [[ ! -f "$HOME/install-scripts/logs/anaconda" ]]; then
	center "${GREEN}Downloading Anaconda 3 Edition 2021-05${NORMAL}"
		rm -rf ${TEMP_DIR}/Anaconda3-2021.05-Linux-x86_64.sh
		wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh -P ${TEMP_DIR}
		chmod +x ${TEMP_DIR}/Anaconda3-2021.05-Linux-x86_64.sh
		sh ${TEMP_DIR}/Anaconda3-2021.05-Linux-x86_64.sh -b -p $MODULE_PREFIX/anaconda3
		touch $HOME/install-scripts/logs/anaconda
	center "${GREEN}Completed${NORMAL}"
fi

if [[ ! -f "$HOME/install-scripts/logs/env_module" ]]; then
	center "${GREEN}Downloading Environment Module${NORMAL}"
		wget https://github.com/cea-hpc/modules/archive/refs/tags/v4.7.1.tar.gz -P ${TEMP_DIR}
		tar -xvf ${TEMP_DIR}/v4.7.1.tar.gz -C ${TEMP_DIR}
		cd ${TEMP_DIR}/modules-4.7.1
		./configure --prefix=$MODULE_PREFIX/environment_modules --modulefilesdir=$MODULE_PREFIX/modules
		make -j 20 && make install
		rm -rf $MODULE_PREFIX/modules
		touch $HOME/install-scripts/logs/env_module
	center "${GREEN}Completed${NORMAL}"
fi

if [[ ! -f "$HOME/install-scripts/logs/modules" ]]; then
	center "${GREEN}Downloading all required modules${NORMAL}"
		cd $MODULE_PREFIX
		if [[ ! -d "$MODULE_PREFIX/modules_source" ]]; then
			git clone --recursive https://github.com/animesh-tool-repo/modules.git modules_source
		else
			cd modules_source && git pull --recurse-submodules
		fi
		mkdir -p modules/python
		mkdir -p modules/golang
		mkdir -p modules/nextstrain
		mkdir -p modules/usher
		mkdir -p modules/anaconda
		mkdir -p modules/bwa
		mkdir -p modules/fastqc
		mkdir -p modules/gatk
		mkdir -p modules/picard
		mkdir -p modules/rclone
		mkdir -p modules/samtools
		mkdir -p modules/seqtk
		ln modules_source/seqtk/1.3 modules/seqtk/1.3
		ln modules_source/usher/0.3 modules/usher/0.3
		ln modules_source/bwa/0.7.17 modules/bwa/0.7.17
		ln modules_source/gatk/3.8.1.0 modules/gatk/3.8.1.0
		ln modules_source/gatk/4.2.2.0 modules/gatk/4.2.2.0
		ln modules_source/gatk/4.1.9.0 modules/gatk/4.1.9.0
		ln modules_source/samtools/1.13 modules/samtools/1.13
		ln modules_source/rclone/1.56.0 modules/rclone/1.56.0
		ln modules_source/fastqc/0.11.9 modules/fastqc/0.11.9
		ln modules_source/golang/1.16.4 modules/golang/1.16.4
		ln modules_source/python/3.9.5 modules/python/3.9.5
		ln modules_source/python/2.7.18 modules/python/2.7.18
		ln modules_source/picard/2.24.0 modules/picard/2.24.0
		ln modules_source/picard/2.26.0 modules/picard/2.26.0
		ln modules_source/anaconda/3-2021.05 modules/anaconda/3-2021.05
		ln modules_source/nextstrain/1.2.3 modules/nextstrain/1.2.3
		ln modules_source/nextstrain/1.0.0_a9 modules/nextstrain/1.0.0_a9

		. $MODULE_PREFIX/environment_modules/init/bash
		touch $HOME/install-scripts/logs/modules
	center "${GREEN}Completed${NORMAL}"
fi

if [[ ! -f "$HOME/install-scripts/logs/bwa_build" ]]; then
	center "${GREEN}Building BWA${NORMAL}"
		cd $MODULE_PREFIX/modules_source/bwa/v0.7.17/
		mkdir -p package
		cd source
		make -j 10
		mv bwa ../package/
		touch $HOME/install-scripts/logs/bwa_build
	center "${GREEN}Completed${NORMAL}"
fi

if [[ ! -f "$HOME/install-scripts/logs/seqtk_build" ]]; then
	center "${GREEN}Building Seqtk${NORMAL}"
		cd $MODULE_PREFIX/modules_source/seqtk/v1.3/
		mkdir -p package
		cd source
		make -j 10
		mv seqtk ../package/
		touch $HOME/install-scripts/logs/seqtk_build
	center "${GREEN}Completed${NORMAL}"
fi

if [[ ! -f "$HOME/install-scripts/logs/samtools_build" ]]; then
	center "${GREEN}Building Samtools${NORMAL}"
		cd $MODULE_PREFIX/modules_source/samtools/v1.13/source
		./configure --prefix $MODULE_PREFIX/modules_source/samtools/v1.13/package --without-curses
		make -j 10 && make install
		make clean
		touch $HOME/install-scripts/logs/samtools_build
	center "${GREEN}Completed${NORMAL}"
fi

if [[ ! -f "$HOME/install-scripts/logs/go_packages" ]]; then
	center "${GREEN}Downloading and Building required go packages${NORMAL}"
		module load golang/1.16.4
		go get -u -ldflags="-s -w" github.com/gokcehan/lf
		go get github.com/cov-ert/gofasta
		touch $HOME/install-scripts/logs/go_packages
	center "${GREEN}Completed${NORMAL}"
fi

# if [[ ! -f "$HOME/install-scripts/logs/usher_build" ]]; then
# 	echo "Building UShER"
# 		cd $MODULE_PREFIX/modules_source/usher/v0.3/source
# 		cd modules/usher/v0.3/source
# 		mkdir -p usher_build && cd usher_build
# 		cmake -DTBB_DIR=${PWD}/../oneTBB-2019_U9 -DCMAKE_PREFIX_PATH=${PWD}/../oneTBB-2019_U9/cmake ..
# 		make -j 20
# 		mkdir -p ../../package
# 		cp parsimony.pb.h parsimony.pb.cc matOptimize usher matUtils ../../package/
# 		cd ../..
# 		rm -rf source/usher_build source/oneTBB-2019_U9/cmake/TBBConfig.cmake source/oneTBB-2019_U9/cmake/TBBConfigVersion.cmake
# 		touch $HOME/install-scripts/logs/usher_build
# 	echo "Completed"
# fi

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

# echo "Appending lines to bashrc"
# echo 'export MODULE_PREFIX="$HOME/Installed_Package"' >> ~/.bash_profile
# echo '. $MODULE_PREFIX/environment_modules/init/bash' >> ~/.bash_profile
# echo "module load python/3.9.5 golang/1.16.4" >> $MODULE_PREFIX/environment_modules/init/modulerc
# echo "Completed"


# echo "Installing required python packages"
# module load python/3.9.5
# pip install nextstrain-augur snakemake==6.3.0 tqdm bpytop cython fuzzyset arrow pendulum biopython pytools openpyxl
# pip install git+https://github.com/cov-lineages/pangolin.git 
# pip install git+https://github.com/cov-lineages/pangoLEARN.git 
# pip install git+https://github.com/cov-lineages/scorpio.git 
# pip install git+https://github.com/cov-lineages/constellations.git
# echo "Completed"
