#!/bin/bash
#SBATCH --job-name=p2.PATCH_WGS
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=8000
#SBATCH --output=temp/p2.patch_WGS.out.%j
#SBATCH --partition="brc"
#SBATCH --requeue
#SBATCH --exclude=nodeb01,nodec03,nodec12,noded03,noded13,nodec21
#SBATCH --time=6:00:00

# load modules via library
source ~/microbiome/PATCH-pipeline-main/WGS/scripts/library.sh

echo "DO NOT RUN this script directly, use the run.sh"
sleep 10

FILE_R1=$1
FILE_R2=$2
FILE_PREFIX=$3
FRAGMENT_SIZE=$4

# Denovo assemlbly of unmapped reads using SPAdes
#$SPADES_PATH -1 $FILE_R1 -2 $FILE_R2 --only-assembler -o output/${FILE_PREFIX}.spades

if [ ${FRAGMENT_SIZE} == "LONG" ]; then
  #Run kraken for pathogen classification
  echo "running kraken on tumor/normal output (non-plasma). Use paired reads input"

  $KRAKEN_PATH --use-names --db $KRAKEN_DB_PATH \
  --report output/$FILE_PREFIX.kraken_report.txt \
  --classified-out output/$FILE_PREFIX#.kraken_classifications.txt \
  --paired $FILE_R1 $FILE_R2 >> output/$FILE_PREFIX.output_kraken.txt

else
  # Run flash
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

#echo "grepping pathogen of interest"
#grep -e 'pathogen_of_interest' output/$FILE_PREFIX.output_kraken.txt | awk '{print $2}' > output/$FILE_PREFIX.pathogen_nodes.txt

# extract sequences using subseq?
#$SEQTK_PATH subseq output/${FILE_PREFIX}.spades/scaffolds.fasta output/$FILE_PREFIX.pathogen_nodes.txt > output/$FILE_PREFIX.pathogen_sequences.fasta

# /scratch/users/k1802884/tools/ncbi-blast-2.10.1+/bin/blastn -query kraken_2021/fuso_seq_21.fasta -db pathogens_of_interest_ref_database.fa \
# -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle' \
# -max_target_seqs 1 -max_hsps 1 -out output/kraken/pathogen_gene_annotation.blastn
#
#
# Centrifuge (added to path - )
#centrifuge-kreport -x /scratch/users/k1802884/azure/radhika/centrifuge/p_compressed+h+v
# -f spades/transcripts.fasta \
# --report-file output/centrifuge/centrifuge_report.txt -S output/centrifuge/centrifuge_output.txt
#
# grep -e 'pathogen_of_interest' output/centrifuge/centrifuge_report.txt | awk '{print $3}' | sort | uniq > output/centrifuge/tax_id_list.txt
# awk -F' ' 'NR==FNR{c[$1]++;next};c[$3]' tax_id_list.txt output/centrifuge/centrifuge_output.txt | awk '{print $1}' | sort -u | uniq > output/centrifuge/pathogen_nodes.txt
# /scratch/users/k1802884/tools/seqtk/seqtk subseq spades/transcripts.fasta output/centrifuge/pathogen_nodes.txt > output/centrifuge/pathogen_sequences.fasta
#
# /scratch/users/k1802884/tools/ncbi-blast-2.10.1+/bin/blastn -query output/centrifuge/pathogen_sequences.fasta -db /pathogens_of_interest_ref_database.fa \
# 	-outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle' \
# 	-max_target_seqs 1 -max_hsps 1 -out output/centrifuge/pathogen_gene_annotation.blastn
#
# #Run BLASTn for pathogen classification
# mkdir output/blastn
# /scratch/users/k1802884/tools/ncbi-blast-2.10.1+/bin/blastn -db /scratch/users/k1802884/azure/radhika/blast_nt/nt -query spades/transcripts.fasta -num_threads 16 \
# -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle' \
# -max_target_seqs 1 -max_hsps 1 -out output/blastn/blastn_output.txt
#
# grep -e 'pathogen_of_interest' output/blastn/blastn_output.txt | awk '{print $1}' | sort -u | uniq > output/blastn/pathogen_nodes.txt
# /scratch/users/k1802884/tools/seqtk/seqtk subseq spades/transcripts.fasta blastn/pathogen_nodes.txt > output/blastn/pathogen_reads.fasta
#
# /scratch/users/k1802884/tools/ncbi-blast-2.10.1+/bin/blastn -query output/blastn/pathogen_reads.fasta -db output/pathogens_of_interest_ref_database.fa \
# -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle' \
# -max_target_seqs 1 -max_hsps 1 -out output/blastn/pathogen_gene_annotation.blastn
