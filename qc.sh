#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 05:00:00
#SBATCH -J qc

module load bioinfo-tools
module load FastQC
module load MultiQC

for t in /crex/proj/snic2021-23-717/private/trimmed/human/*.fastq.gz
do
	fastqc $t -o /home/linne/exjobb/preprocessing/human_data/post-trimming
done

multiqc /home/linne/exjobb/preprocessing/human_data/post-trimming -o /home/linne/exjobb/preprocessing/human_data/post-trimming
