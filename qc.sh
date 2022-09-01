#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 05:00:00
#SBATCH -J qc

module load bioinfo-tools
module load FastQC
module load MultiQC

path_to_reads="/path/to/reads"
path_to_qc_outdir="/path/to/qc/outdir"

for t in ${path_to_reads}/*.fastq.gz
do
	fastqc $t -o ${path_to_qc_outdir}
done

multiqc ${path_to_qc_outdir} -o ${path_to_qc_outdir}
