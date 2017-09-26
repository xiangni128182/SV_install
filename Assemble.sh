#!/usr/bin/bash

BAM=${1}
REGION=${2}

~/Tools/chm1_scripts-master/./RegionToFasta.py ${BAM} ${REGION}region.txt --out ${REGION}region/reads.fasta  --max 10000 --subsample
~/Tools/chm1_scripts-master/./FastaToFakeFastq.py ${REGION}region/reads.fasta ${REGION}region/reads.fastq
# wc -l ${REGION}region/reads.fastq