#!/bin/bash

#=======================
# cfdna microbiome library
#
# Author: Jonathan C M Wan
#=======================

# modules
module load apps/bwa/0.7.17-singularity
module load apps/bedtools2/2.29.0
module load apps/openjdk
module load apps/trimmomatic/0.39
module load apps/fastqc/0.11.8

# tools
KRAKEN_PATH="/scratch/groups/cancerbioinformatics/cancer_microbiome/tools/kraken2-2.0.8-beta/kraken2"
PICARD_PATH="/scratch/groups/cancerbioinformatics/software/picard_2.25.5/picard.jar"
TRIMMOMATIC_PATH="/scratch/users/k2034906/software/Trimmomatic-0.39/trimmomatic-0.39.jar"
FLASH_PATH="/scratch/users/k2034906/software/FLASH-1.2.11-Linux-x86_64/flash"

# databases
KRAKEN_DB_PATH="/scratch/groups/cancerbioinformatics/cancer_microbiome/databases/kraken2/refseq/standard" # obtained from https://benlangmead.github.io/aws-indexes/k2
ADAPTORS_PATH="/scratch/users/k2034906/software/Trimmomatic-0.39/adapters/TruSeq3-PE-2.fa"
