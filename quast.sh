#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 05:00:00
#SBATCH -J quast

module load bioinfo-tools
module load quast

path_to_filtered_assemblies="/path/to/filtered_assemblies/"
path_to_quast_outdir="/path/to/quast_outdir"
path_to_reference="path/to/ref"

for a in ${path_to_filtered_assemblies}/*.fasta
do
	ID=$(basename $a _filtered.fasta)

	if [[ ! -d ${path_to_quast_outdir}/$ID ]]
	then
		mkdir ${path_to_quast_outdir}/$ID
	fi

	quast.py --threads 2 -r ${path_to_reference}/TW14359.fasta -o ${path_to_quast_outdir}/$ID $a
done
