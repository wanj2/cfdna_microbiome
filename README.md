# Code repository for 'Microbial cfDNA in non-small cell lung cancer pre- and post-surgery'

### Author
Jonathan C. M. Wan

### Date
September 2023

### Description
This repository contains code for processing cfDNA microbial sequence data using unmapped reads. 

`run.p1.bam_input.sh` takes aligned BAMs, generates QC metrics, converts to raw FASTQ and trims reads.

`run.p2.kraken.sh' takes trimmed FASTQ files and runs Kraken on these reads, to generate counts of each microbial genus present in each sample. For cfDNA input, FLASH is run to reduce error rates in the overlapping region of mate pairs.

### Input
Aligned BAMs to human genome (including unmapped reads). If FASTQ files are already available, then apply Kraken directly.

### Output
Kraken classification .txt files

### Software/inputs used
- Kraken2 (2-2.0.8-beta)
- Kraken2 database: RefSeq standard
- Picard (2.25.5)
- Trimmomatic (0.39)
- Adaptors: TruSeq3-PE-2.fa
- FLASH (1.2.11-Linux-x86_64)

### Contact
jonathan.wan@kcl.ac.uk




