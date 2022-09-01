#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 2
#SBATCH -t 05:00:00
#SBATCH -J prokka

module load bioinfo-tools
module load prokka

for a in /crex/proj/snic2021-23-717/private/filtered_assembly/klad8/*.fasta
do
	id=$(basename $a _filtered.fasta)
	prokka --outdir /crex/proj/snic2021-23-717/private/prokka/${id} --force --prefix ${id} --locustag ${id} --genus Escherichia --strain coli --usegenus $a
done
