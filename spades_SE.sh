#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 8
#SBATCH -t 30:00:00
#SBATCH -J spades_human
#SBATCH --mail-type=ALL
#SBATCH --mail-user linnea.gauffingood.6719@student.uu.se

module load bioinfo-tools
module load spades

if test -f "spades_script_human.sh"; then
        rm spades_script_human.sh
fi

regex="[^_]*"

for i in /crex/proj/snic2021-23-717/private/exjobb/trimmed/human_O157_klad8/*.fastq.gz
do

	basename=$(basename $i)
	if [[ ${basename} =~ $regex ]]
	then
		basename=${BASH_REMATCH[*]}
	fi

        if [[ ! -d /crex/proj/snic2021-23-717/private/exjobb/assembly/human/$basename ]]
        then
                mkdir /crex/proj/snic2021-23-717/private/exjobb/assembly/human/$basename
        fi

        echo "spades.py -s $i -m 50 --careful -o /crex/proj/snic2021-23-717/private/exjobb/assembly/human/$basename" > spades_script_human.sh
        bash spades_script.sh

done
