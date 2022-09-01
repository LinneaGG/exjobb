#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 8
#SBATCH -t 30:00:00
#SBATCH -J spades_SE

module load bioinfo-tools
module load spades

path_to_trimmed_reads="/path/to/trimmed_reads"
path_to_assembly_outdir="/path/to/assembly/outdir"

if test -f "spades_script_human.sh"; then
        rm spades_script_human.sh
fi

regex="[^_]*" #Keeps only the part before the first _ of the file name, may need to be changed depending on the IDs

for i in ${path_to_trimmed_reads}/*.fastq.gz
do

	basename=$(basename $i)
	if [[ ${basename} =~ $regex ]]
	then
		basename=${BASH_REMATCH[*]}
	fi

        if [[ ! -d ${path_to_assembly_outdir}/$basename ]]
        then
                mkdir ${path_to_assembly_outdir}/$basename #Create directory for each isolate in assembly outdir
        fi

        echo "spades.py -s $i -m 50 --careful -o ${path_to_assembly_outdir}/$basename" > spades_script_human.sh
        bash spades_script.sh

done
