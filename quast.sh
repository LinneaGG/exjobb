#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 05:00:00
#SBATCH -J quast

module load bioinfo-tools
module load quast

assemblies=/path/to/filtered_assemblies/*.fasta

for a in $assemblies
do
	ID=$(basename $a _filtered.fasta)

	if [[ ! -d /crex/proj/snic2021-23-717/private/quast_human/$ID ]]
	then
		mkdir /crex/proj/snic2021-23-717/private/quast_human/$ID
	fi

	quast.py --threads 2 -r /home/linne/exjobb/snp_analysis/TW14359.fasta -o /crex/proj/snic2021-23-717/private/quast_human/$ID $a
done
