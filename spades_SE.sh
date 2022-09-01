#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 8
#SBATCH -t 30:00:00
#SBATCH -J spades_SE
#SBATCH --mail-type=ALL
#SBATCH --mail-user linnea.gauffingood.6719@student.uu.se

module load bioinfo-tools
module load spades

if test -f "spades_script_human.sh"; then
        rm spades_script_human.sh
fi

regex="[^_]*"

for i in /path/to/trimmed_reads/*.fastq.gz
do

	basename=$(basename $i)
	if [[ ${basename} =~ $regex ]]
	then
		basename=${BASH_REMATCH[*]}
	fi

        if [[ ! -d /path/to/assembly_outdir/$basename ]]
        then
                mkdir /path/to/assembly_outdir/$basename #Create directory for each isolate in assembly outdir
        fi

        echo "spades.py -s $i -m 50 --careful -o /path/to/assembly_outdir/$basename" > spades_script_human.sh
        bash spades_script.sh

done
