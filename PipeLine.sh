#!/usr/bin/bash

# time_start=$(date +%s)
# time_end=$(date +%s)
# echo " $[$time_end-$time_start] sec."

BlasrPath=/home/tjiang/Tools/blasr-master/alignment/bin/
chm1_path=/home/tjiang/Tools/chm1_scripts-master/
Index_path=/home/tjiang/hg19.new.fa
bedtools_path=/home/tjiang/Tools/bedtools2/bin/
repeatmasker_path=/home/tjiang/Tools/RepeatMasker/
samtool_path=/home/tjiang/Tools/samtools/

#para_1 input_fasta

#step 1 alignment
echo "step Blasr"
${BlasrPath}./blasr $1 ${Index_path} -sa ${Index_path}.sa -ctab ${Index_path}.ctab -affineAlign -affineOpen 100 -affineExtend 0 -insertion 0 -deletion 0 -nproc 32 -out $1.sam -bestn 1 -sam  -maxMatch 50
${samtool_path}./samtools view -bS $1.sam | ${samtool_path}./samtools sort - $1
${samtool_path}./samtools index $1.bam

#step2 produce gaps.bed
echo "step printgaps"
${chm1_path}./PrintGaps.py ${Index_path} $1.sam --condense 20 --tsd 20 --outFile gaps.bed

#insertions filter insertion
echo "step filter insertions"
grep insertion gaps.bed | ${bedtools_path}./bedtools sort | ${chm1_path}./rmdup.py /dev/stdin insertions.bed --leftjustify --window 100
${chm1_path}./FilterEventListByAssembledTarget.py insertions.bed insertions.bed.tmp
mv insertions.bed.tmp insertions.bed
grep -s -v "chrY" insertions.bed > insertions.bed.tmp
mv -f insertions.bed.tmp insertions.bed
#deletions filter deletion
echo "step filter deletions"
grep deletion gaps.bed | ${bedtools_path}./bedtools sort | ${chm1_path}./rmdup.py /dev/stdin deletions.bed --leftjustify --window 100
${chm1_path}./FilterEventListByAssembledTarget.py deletions.bed deletions.bed.tmp
mv -f deletions.bed.tmp deletions.bed
grep -s -v "chrY" deletions.bed > deletions.bed.tmp
mv -f deletions.bed.tmp deletions.bed

#step3 change format
echo "step change format"
mkdir -p insertion
mkdir -p deletion
${chm1_path}./GapBedToFasta.py insertions.bed insertion/insertions.fasta
${chm1_path}./GapBedToFasta.py deletions.bed deletion/deletions.fasta

#step4 repeatmasker
mkdir -p insertion/rm
mkdir -p deletion/rm

${repeatmasker_path}./RepeatMasker -xsmall -dir insertion/rm -pa 8 insertion/insertions.fasta
${repeatmasker_path}./RepeatMasker -xsmall -dir deletion/rm -pa 8 deletion/deletions.fasta

${chm1_path}./AnnotateGapBed.py deletions.bed deletion/deletions.annotated.bed deletion/rm/deletions.fasta.out deletion/rm/deletions.fasta.masked
# ${chm1_path}./AnnotateGapBedWithCensorMap.py deletions.bed deletion/rm/deletions.fasta.map deletion/deletions.annotated.bed
grep NONE deletion/deletions.annotated.bed > deletion/deletions.NONE.bed
grep -v NONE deletion/deletions.annotated.bed > tmp
mv tmp deletion/deletions.annotated.all.bed
cat deletion/deletions.annotated.all.bed | awk '{if ($10 < 0.70) print}' > deletion/deletions.partial_masked.bed
cat deletion/deletions.annotated.all.bed | awk '{ if ($10 >= 0.70) print}' > deletion/deletions.annotated.bed

${chm1_path}./AnnotateGapBed.py insertions.bed insertion/insertions.annotated.bed insertion/rm/insertions.fasta.out insertion/rm/insertions.fasta.masked
# ${chm1_path}./AnnotateGapBedWithCensorMap.py insertions.bed insertion/rm/insertions.fasta.map insertion/insertions.annotated.bed
grep NONE insertion/insertions.annotated.bed > insertion/insertions.NONE.bed
grep -v NONE insertion/insertions.annotated.bed > tmp
mv tmp insertion/insertions.annotated.all.bed
cat insertion/insertions.annotated.all.bed | awk '{ if ($10 < 0.50) print}' > insertion/insertions.partial_masked.bed
cat insertion/insertions.annotated.all.bed | awk '{ if ($10 >= 0.50) print}' > insertion/insertions.annotated.bed

bash ${chm1_path}PrintUniqueEvents.sh insertion/insertions.annotated.bed insertion
rm -rf insertion/[0-9]*
mkdir insertion/full
mv insertion/ins* insertion/full

bash ${chm1_path}PrintUniqueEvents.sh deletion/deletions.annotated.bed deletion
rm -rf deletion/[0-9]*
mkdir deletion/full
mv deletion/del* deletion/full