#!/usr/bin/bash

if [[ $# < 1 ]]; then
	echo "usage Honey_pipeline.sh Reference Reads outputPrefix threads"
	exit
fi
Reference=${1}
Reads=${2}
outputPrefix=${3}
threads=${4}
tmpdir=temp

TIMES=$(date +%s)
echo "Honey-PIE"
mkdir -p ${tmpdir}
Honey.py pie -n ${threads} -o ${outputPrefix}.sam ${Reads} ${Reference} --temp ${tmpdir}
rm -rf ${tmpdir}
echo "File Transform: SAM -> BAM"
sam2bam ${Reference} ${outputPrefix}.sam
echo "Honey-TAILS"
Honey.py tails ${outputPrefix}.bam
# -B 1000 -f -v -o tail2
echo "Honey-SPOTS"
Honey.py spots --reference ${Reference} -n ${threads} ${outputPrefix}.bam --readFile
echo "Tails & Spots to BED"
spotToBed.py ${outputPrefix}.hon.spots > ${outputPrefix}.spots.bed
tailToBed.py ${outputPrefix}.hon.tails > ${outputPrefix}.tails.bed
cat ${outputPrefix}.spots.bed  ${outputPrefix}.tails.bed >  ${outputPrefix}.bed
rm ${outputPrefix}.spots.bed 
rm ${outputPrefix}.tails.bed
rm ${outputPrefix}.bam*
TIMEE=$(date +%s)
echo "Pipeline-PBHoney $[$TIMEE-$TIMES] sec."


# echo "Honey-ASM"
# Honey.py asm  ${outputPrefix}.tails.bed -b ${outputPrefix}.bam -n ${threads} -r ${Reference} -o tails.fastq --temp ${tmpdir}
# rm ${tmpdir}/*
# Honey.py asm ${outputPrefix}.spots.bed -b ${outputPrefix}.bam -n ${threads} -r ${Reference} -o spots.fastq --temp ${tmpdir}
# rm ${tmpdir}/*
# rm -r ${tmpdir}
# #something wrong
