#!/bin/bash

#=======================
# Run microbiome WGS profiling - KRAKEN
# 1)
#
# Author: Jonathan C M Wan
#=======================

mkdir output
mkdir temp

SCRIPT=/users/k2034906/cfdna_microbiome/scripts/p2.cfdna_microbiome.sh

echo "running p2 - kraken +/- FLASH"
echo "fastq.gz files need to be in temp to be run"
sleep 10

# run in a loop using SBATCH
for FILE_R1 in $(ls temp/*R1.unmapped.paired.trimmed.fq.gz); do
    FILE_PREFIX=$(echo $FILE_R1 | sed 's/.R1.unmapped.paired.trimmed.fq.gz//g'| cut -d "/" -f 2)
    FILE_R2=$(echo $FILE_R1 | sed "s/R1/R2/g")

    # determine if file is plasma or not
    if echo $FILE_R1 | grep -E 'tumor|normal' -q; then
      echo "long fragment size detected, skipping FLASH"
      FRAGMENT_SIZE="LONG"
      #sleep 1
    else
      echo "short fragment size detected, running FLASH before Kraken"
      FRAGMENT_SIZE="SHORT"
      #sleep 1
    fi

    if [ ! -f output/$FILE_PREFIX.kraken_report.txt ]; then
    echo "sbatch $SCRIPT $FILE_R1 $FILE_R2 $FILE_PREFIX $FRAGMENT_SIZE"
    sbatch $SCRIPT $FILE_R1 $FILE_R2 $FILE_PREFIX $FRAGMENT_SIZE
    else
      echo "output/$FILE_PREFIX.kraken_report.txt already exists, skipping"
    fi

done
