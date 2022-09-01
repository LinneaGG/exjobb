#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 2
#SBATCH -t 05:00:00
#SBATCH -J prokka

module load bioinfo-tools
module load prokka

path_to_filtered_assemblies="/path/to/filtered/assemblies"
path_to_prokka_outdir="/path/to/prokka_outdir"

for a in ${path_to_filtered_assemblies}/*.fasta
do
	id=$(basename $a _filtered.fasta)
	prokka --outdir ${path_to_prokka_outdir}/${id} --force --prefix ${id} --locustag ${id} --genus Escherichia --strain coli --usegenus $a
done
