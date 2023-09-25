#!/bin/bash
#SBATCH --job-name=p2.cfDNA_microbiome
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=8000
#SBATCH --output=temp/p2.cfDNA_microbiome.out.%j
#SBATCH --partition="brc"
#SBATCH --requeue
#SBATCH --exclude=nodeb01,nodec03,nodec12,noded03,noded13,nodec21
#SBATCH --time=6:00:00

# load modules via library
source ~/cfdna_microbiome/scripts/library.sh

echo "DO NOT RUN this script directly, use the run.sh"
sleep 10

FILE_R1=$1
FILE_R2=$2
FILE_PREFIX=$3
FRAGMENT_SIZE=$4

if [ ${FRAGMENT_SIZE} == "LONG" ]; then
  #Run kraken for pathogen classification
  echo "running kraken on tumor/normal output (non-plasma). Use paired reads input"

  $KRAKEN_PATH --use-names --db $KRAKEN_DB_PATH \
  --report output/$FILE_PREFIX.kraken_report.txt \
  --classified-out output/$FILE_PREFIX#.kraken_classifications.txt \
  --paired $FILE_R1 $FILE_R2 >> output/$FILE_PREFIX.output_kraken.txt

else
  # Run flash if fragment size is short, resulting in overlapping mate pairs 
  echo "${FLASH_PATH} --min-overlap=20 --max-overlap=150 --max-mismatch-density=0.01 -o $FILE_PREFIX --output-directory temp $FILE_R1 $FILE_R2"
  ${FLASH_PATH} --min-overlap=20 --max-overlap=150 --max-mismatch-density=0.01 -o $FILE_PREFIX --output-directory temp $FILE_R1 $FILE_R2 # Poore et al: min overlap 20, max overlap 150, mismatch ratio 0.01

  echo "running kraken on FLASH output (plasma)"

  $KRAKEN_PATH --use-names --db $KRAKEN_DB_PATH \
  --report output/$FILE_PREFIX.kraken_report.txt \
  --classified-out output/$FILE_PREFIX.kraken_classifications.txt \
  temp/${FILE_PREFIX}.extendedFrags.fastq \
  >> output/$FILE_PREFIX.flash.output_kraken.txt

fi

# remove/zip intermediate files
rm temp/${FILE_PREFIX}*fastq
gzip output/${FILE_PREFIX}*kraken_classifications.txt
gzip output/${FILE_PREFIX}*output_kraken.txt

