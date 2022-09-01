#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 05:00:00
#SBATCH -J qc

module load bioinfo-tools
module load FastQC
module load MultiQC

for t in /path/to/reads/*.fastq.gz
do
	fastqc $t -o /path/to/fastq_outdir
done

multiqc /path/to/fastq_outdir -o /path/to/multiqc_outdir
