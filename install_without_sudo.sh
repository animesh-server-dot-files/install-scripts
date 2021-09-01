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
		rm -rf ${TEMP_DIR}/v4.7.1.tar.gz ${TEMP_DIR}/modules-4.7.1
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
		if [[ -d "$MODULE_PREFIX/modules_source" ]]; then
			rm -rf $MODULE_PREFIX/modules_source
		fi
		git clone --recursive https://github.com/animesh-tool-repo/modules.git $MODULE_PREFIX/modules_source
		mkdir -p $MODULE_PREFIX/modules/python
		mkdir -p $MODULE_PREFIX/modules/golang
		mkdir -p $MODULE_PREFIX/modules/nextstrain
		mkdir -p $MODULE_PREFIX/modules/usher
		mkdir -p $MODULE_PREFIX/modules/anaconda
		mkdir -p $MODULE_PREFIX/modules/bwa
		mkdir -p $MODULE_PREFIX/modules/fastqc
		mkdir -p $MODULE_PREFIX/modules/gatk
		mkdir -p $MODULE_PREFIX/modules/picard
		mkdir -p $MODULE_PREFIX/modules/rclone
		mkdir -p $MODULE_PREFIX/modules/samtools
		mkdir -p $MODULE_PREFIX/modules/seqtk
		ln $MODULE_PREFIX/modules_source/seqtk/1.3 $MODULE_PREFIX/modules/seqtk/1.3
		ln $MODULE_PREFIX/modules_source/usher/0.3 $MODULE_PREFIX/modules/usher/0.3
		ln $MODULE_PREFIX/modules_source/bwa/0.7.17 $MODULE_PREFIX/modules/bwa/0.7.17
		ln $MODULE_PREFIX/modules_source/gatk/3.8.1.0 $MODULE_PREFIX/modules/gatk/3.8.1.0
		ln $MODULE_PREFIX/modules_source/gatk/4.2.2.0 $MODULE_PREFIX/modules/gatk/4.2.2.0
		ln $MODULE_PREFIX/modules_source/gatk/4.1.9.0 $MODULE_PREFIX/modules/gatk/4.1.9.0
		ln $MODULE_PREFIX/modules_source/samtools/1.13 $MODULE_PREFIX/modules/samtools/1.13
		ln $MODULE_PREFIX/modules_source/rclone/1.56.0 $MODULE_PREFIX/modules/rclone/1.56.0
		ln $MODULE_PREFIX/modules_source/fastqc/0.11.9 $MODULE_PREFIX/modules/fastqc/0.11.9
		ln $MODULE_PREFIX/modules_source/golang/1.16.4 $MODULE_PREFIX/modules/golang/1.16.4
		ln $MODULE_PREFIX/modules_source/python/3.9.5 $MODULE_PREFIX/modules/python/3.9.5
		ln $MODULE_PREFIX/modules_source/python/2.7.18 $MODULE_PREFIX/modules/python/2.7.18
		ln $MODULE_PREFIX/modules_source/picard/2.24.0 $MODULE_PREFIX/modules/picard/2.24.0
		ln $MODULE_PREFIX/modules_source/picard/2.26.0 $MODULE_PREFIX/modules/picard/2.26.0
		ln $MODULE_PREFIX/modules_source/anaconda/3-2021.05 $MODULE_PREFIX/modules/anaconda/3-2021.05
		ln $MODULE_PREFIX/modules_source/nextstrain/1.2.3 $MODULE_PREFIX/modules/nextstrain/1.2.3
		ln $MODULE_PREFIX/modules_source/nextstrain/1.0.0_a9 $MODULE_PREFIX/modules/nextstrain/1.0.0_a9

		touch $HOME/install-scripts/logs/modules
	center "${GREEN}Completed${NORMAL}"
fi

if [[ ! -f "$HOME/install-scripts/logs/conda_install" ]]; then
	center "$MODULE_PREFIX/Configuring Anaconda and Installing required packages${NORMAL}"
		. $MODULE_PREFIX/environment_modules/init/bash
		module load anaconda/3-2021.05
		conda config --add channels bioconda
		conda config --add channels anaconda
		conda config --add channels conda-forge
		# conda install --yes -c conda-forge compilers
		conda install --yes ncurses cmake protobuf boost git
		conda create --yes -n python_3.9 python=3.9
		conda create --yes -n python_2.7 python=2.7
		module unload anaconda/3-2021.05
		touch $HOME/install-scripts/logs/conda_install
	center "$MODULE_PREFIX/Completed${NORMAL}"
fi

if [[ ! -f "$HOME/install-scripts/logs/bwa_build" ]]; then
	center "$MODULE_PREFIX/Building BWA${NORMAL}"
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
		. $MODULE_PREFIX/environment_modules/init/bash
		module load anaconda/3-2021.05
		conda activate base
		cd $MODULE_PREFIX/modules_source/samtools/v1.13/source
		./configure --prefix $MODULE_PREFIX/modules_source/samtools/v1.13/package
		make -j 10 && make install
		make clean
		touch $HOME/install-scripts/logs/samtools_build
	center "${GREEN}Completed${NORMAL}"
fi

if [[ ! -f "$HOME/install-scripts/logs/go_packages" ]]; then
	center "${GREEN}Downloading and Building required go packages${NORMAL}"
		. $MODULE_PREFIX/environment_modules/init/bash
		module load golang/1.16.4
		go get -u -ldflags="-s -w" github.com/gokcehan/lf
		go get github.com/cov-ert/gofasta
		touch $HOME/install-scripts/logs/go_packages
	center "${GREEN}Completed${NORMAL}"
fi

if [[ ! -f "$HOME/install-scripts/logs/module_bash" ]]; then
	center "${GREEN}Appending lines to bashrc${NORMAL}"
		echo 'export MODULE_PREFIX="$HOME/Installed_Package"' >> ~/.bash_profile
		echo '. $MODULE_PREFIX/environment_modules/init/bash' >> ~/.bash_profile
		echo "module load python/3.9.5 golang/1.16.4" >> $MODULE_PREFIX/environment_modules/init/modulerc
		touch $HOME/install-scripts/logs/module_bash
	center "${GREEN}Completed${NORMAL}"
fi

# echo "Installing required python packages"
# module load python/3.9.5
# pip install nextstrain-augur snakemake==6.3.0 tqdm bpytop cython fuzzyset arrow pendulum biopython pytools openpyxl
# pip install git+https://github.com/cov-lineages/pangolin.git 
# pip install git+https://github.com/cov-lineages/pangoLEARN.git 
# pip install git+https://github.com/cov-lineages/scorpio.git 
# pip install git+https://github.com/cov-lineages/constellations.git
# echo "Completed"
