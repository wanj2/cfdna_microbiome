#!/bin/bash
#SBATCH --job-name=p1.PATCH_WGS.JW
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=8000
#SBATCH --output=temp/p1.patch_WGS.out.%j
#SBATCH --partition="brc"
#SBATCH --requeue
#SBATCH --exclude=nodeb01,nodec03,nodec12,noded03,noded13,nodec21
#SBATCH --time=24:00:00

# load modules via library
source ~/microbiome/PATCH-pipeline-main/WGS/scripts/library.sh

FILE=$1
FILE_PREFIX=$2

echo $FILE > output/$FILE_PREFIX.log

if [ ! -f temp/$FILE_PREFIX.unmapped.R1.fq.gz ]; then
   run fastqc & size profile on original bam
  echo "unmapped FASTQ doesn't exist"
  echo "run QC metrics on BAM, then generate unmapped BAM & FASTQ"

  fastqc $FILE

  echo "running size profile on original bam (mapped reads)"
  java -Xmx20G -jar $PICARD_PATH CollectInsertSizeMetrics \
      I=$FILE\
      O=temp/${FILE_PREFIX}.mapped.insert_size_metrics.txt \
      H=temp/${FILE_PREFIX}.mapped.sorted.hist.pdf

  #Extract "unmapped"/ non-human reads using samtools flags. also print header
  # read unmapped = 4
  # mate unmapped = 8
  # therefore, -f 12
  samtools view -f 12 -h $FILE > temp/$FILE_PREFIX.unmapped.bam # for storage
  echo $FILE Unmapped extracted

  #echo "saving first 500 lines as sam for QC purposes"
  #samtools view -h temp/$FILE_PREFIX.unmapped.bam | head -n 500 > temp/$FILE_PREFIX.500_lines_qc.sam

  # run fastqc on unmapped bam
  echo "run fastqc on unmapped bam (pre-sorting by names)"
  fastqc temp/${FILE_PREFIX}.unmapped.bam

  # count total unmapped reads
  TOTAL_READS=$(samtools view -c temp/$FILE_PREFIX.unmapped.bam)
  echo "unmapped reads:" $TOTAL_READS >> output/$FILE_PREFIX.log

  #Sort the unmapped bam
  echo "sorting unmapped bam by coordinates"
  samtools sort -n temp/$FILE_PREFIX.unmapped.bam > temp/${FILE_PREFIX}.unmapped.sorted.bam

  # run fastqc on unmapped bam
  echo "run fastqc on unmapped"
  fastqc temp/${FILE_PREFIX}.unmapped.sorted.bam

  #Convert to fastq
  echo "converting unmapped bam to fastq"
  bedtools bamtofastq -i temp/${FILE_PREFIX}.unmapped.sorted.bam -fq temp/$FILE_PREFIX.unmapped.R1.fq -fq2 temp/$FILE_PREFIX.unmapped.R2.fq

  #gzip
  echo "gzipping"
  gzip temp/$FILE_PREFIX.unmapped.R1.fq # for storage
  gzip temp/$FILE_PREFIX.unmapped.R2.fq
else
  echo "temp/$FILE_PREFIX.unmapped.R1.fq.gz exists, skip to trimming"
fi

# trimmomatic (using same settings as Poore et al. 2020)  . 
echo "settings (similar to Poore et al.): ILLUMINACLIP:${ADAPTORS_PATH}:2:30:7, MINLEN:50, TRAILING:20, AVGQUAL:20, SLIDINGWINDOW:20:20"
java -jar $TRIMMOMATIC_PATH PE temp/$FILE_PREFIX.unmapped.R1.fq.gz temp/$FILE_PREFIX.unmapped.R2.fq.gz \
temp/$FILE_PREFIX.R1.unmapped.paired.trimmed.fq.gz temp/$FILE_PREFIX.R1.unmapped.unpaired.trimmed.fq.gz \
temp/$FILE_PREFIX.R2.unmapped.paired.trimmed.fq.gz temp/$FILE_PREFIX.R2.unmapped.unpaired.trimmed.fq.gz \
ILLUMINACLIP:${ADAPTORS_PATH}:2:30:7 MINLEN:50 TRAILING:20 AVGQUAL:20 SLIDINGWINDOW:20:20 #ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:7, MINLEN:50, TRAILING:20, AVGQUAL:20, SLIDINGWINDOW:20:20

# run fastqc on unmapped bam
echo "run fastqc on trimmed, unmapped reads"
fastqc temp/$FILE_PREFIX.R1.unmapped.paired.trimmed.fq.gz
fastqc temp/$FILE_PREFIX.R2.unmapped.paired.trimmed.fq.gz

# QC number of reads in fastq
TOTAL_LINES_FQ=$(zcat temp/$FILE_PREFIX.R1.unmapped.paired.trimmed.fq.gz | wc -l )
echo "FASTQ_R1_lines:" $TOTAL_LINES_FQ >> output/$FILE_PREFIX.log

# remove intermediate files
rm temp/$FILE_PREFIX.unmapped.bam
# need to also remove original bam
