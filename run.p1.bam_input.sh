#!/bin/bash

#=======================
# Run microbiome WGS profiling - preprocessing
# 1) QC original bam - fastqc and size profile
# 2) generate unmapped reads as FASTQ, and re-run FASTQC
# 3) reapply read trimming to new FASTQ
#
# Input = aligned BAM to human genome (including unmapped reads)
# Output = trimmed FASTQ of unmapped reads only, ready for input into kraken
#
# Author: Jonathan C M Wan
#=======================

mkdir output
mkdir temp

SCRIPT=/users/k2034906/cfdna_microbiome/scripts/p1.cfdna_microbiome.sh

echo "running p1 - preprocessing of aligned bams"
sleep 10

# run in a loop using SBATCH
for FILE in $(ls input/*bam); do
    FILE_PREFIX=$(echo $FILE | sed 's/.bam//g'| cut -d "/" -f 2)

      echo "sbatch $SCRIPT $FILE $FILE_PREFIX"
      sbatch $SCRIPT $FILE $FILE_PREFIX

done
