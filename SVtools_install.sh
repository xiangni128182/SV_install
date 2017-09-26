#/usr/bin

ENV=/home/tjiang/Tools/CHN100K/tools/bin
Tools=/home/tjiang/Tools/CHN100K/tools

# breakdancer
cd $Tools
git clone --recursive https://github.com/genome/breakdancer.git
cd breakdancer/
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=$ENV
make
make install

# delly2
cd $Tools
git clone --recursive https://github.com/dellytools/delly.git
cd delly/
make all
make PARALLEL=8 -B src/delly
# export OMP_NUM_THREADS=3
cp src/delly $ENV/bin 

# pindel
cd $Tools
git clone https://github.com/samtools/htslib
autoheader     # If using configure, generate the header template...
autoconf       # ...and configure script (or use autoreconf to do both)
./configure --prefix=$ENV    # Optional, needed for choosing optional functionality
make
make install
cd $Tools
git clone --recursive https://github.com/genome/pindel.git
./INSTALL $Tools/htslib
cp pindel $ENV/bin



# ReadDepth

# #install a few packages from bioconductor
# source("http://bioconductor.org/biocLite.R")
# biocLite(c("IRanges","foreach","doMC","DNAcopy"))
# #install devtools if you don't have it already
# install.packages("devtools")
# library(devtools)
# install_github("chrisamiller/readDepth")

git clone https://github.com/chrisamiller/readDepth.git
R CMD build readDepth
R CMD INSTALL readDepth_0.9.8.4.tar.gz
cd root-6.10.02/
./configure --prefix=$ENV
make

# CNVnator
cd $Tools
wget https://root.cern.ch/download/root_v6.10.02.source.tar.gz
tar zxf root_v6.10.02.source.tar.gz


cd $Tools
git clone https://github.com/abyzovlab/CNVnator.git
cd CNVnator
export C_INCLUDE_PATH=$ENV/include/htslib


# LUMPY
cd $Tools
git clone --recursive https://github.com/arq5x/lumpy-sv.git
make
cp bin/* $ENV/bin/.