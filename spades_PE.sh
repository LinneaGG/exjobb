#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 8
#SBATCH -t 30:00:00
#SBATCH -J spades

module load bioinfo-tools
module load spades

regex="[^_]*" #Keeps only the part before the first _ of the file name, may need to be changed depending on the IDs

#Two for loops because I had paired files with two different naming schemes
counter1=1
for i in /path/to/trimmed/reads/*R1*_paired* 
do
	counter2=1 
	for j in /path/to/trimmed_reads/*R2*_paired*
	do 
		if [[ $counter1 -eq $counter2 ]] 
		then
			basename=$(basename $i)
			if [[ ${basename} =~ $regex ]]
                        then
                                basename=${BASH_REMATCH[*]}
                        fi
			
			if [[ ! -d /path/to/assembly_outdir/$basename ]] 
			then
				mkdir /path/to/assembly_outdir/$basename #Create directory for each isolate in assembly outdir
			fi
			
			echo "spades.py -1 $i -2 $j -m 50 --careful -o /path/to/assembly_outdir/$basename" > spades_script.sh
			bash spades_script.sh
		fi
		counter2=$((counter2+1))
	done 
counter1=$((counter1+1))
done 

counter1=1
for i in /path/to/trimmed_reads/*_1*_paired*
do
        counter2=1
        for j in /path/to/trimmed_reads/*_2*_paired*
        do
                if [[ $counter1 -eq $counter2 ]]
                then
			basename=$(basename $i)
                        if [[ ${basename} =~ $regex ]]
                        then
                                basename=${BASH_REMATCH[*]}
                        fi

                        if [[ ! -d /path/to/assembly_outdir/$basename ]]
                        then
                                mkdir /path/to/assembly_outdir/$basename
                        fi

                        echo "spades.py -1 $i -2 $j -m 50 --careful -o /path/to/assembly_outdir/$basename" > spades_script.sh
                        bash spades_script.sh
                fi
                counter2=$((counter2+1))
        done
counter1=$((counter1+1))
done
