#!/usr/bin/bash

i=1
if [[ $# < 1 ]]; then
		echo "usage TransRegions.sh regions.bed [slop] [slop outputdir]"
		exit
fi

if [[ $# > 1 ]]; then
  slop="--slop $2"
else
  slop=""
fi
if [[ $# > 2 ]]; then
  output=$3
else
  output=output
fi

for line in `~/Tools/chm1_scripts-master/./GetRegionFromBed.py $1 $slop`; do
		mkdir -p $output/rgn_$i/region
		echo $line > $output/rgn_$i/region.txt
		i=$(($i+1))
done

