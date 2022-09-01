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
for i in /crex/proj/snic2021-23-717/private/trimmed/klad8/*R1*_paired* 
do
	counter2=1 
	for j in /crex/proj/snic2021-23-717/private/trimmed/klad8/*R2*_paired*
	do 
		if [[ $counter1 -eq $counter2 ]] 
		then
			basename=$(basename $i)
			if [[ ${basename} =~ $regex ]]
                        then
                                basename=${BASH_REMATCH[*]}
                        fi
			
			if [[ ! -d /crex/proj/snic2021-23-717/private/assembly/$basename ]]
			then
				mkdir /crex/proj/snic2021-23-717/private/assembly/$basename
			fi
			
			echo "spades.py -1 $i -2 $j -m 50 --careful -o /crex/proj/snic2021-23-717/private/assembly/$basename" > spades_script.sh
			bash spades_script.sh
		fi
		counter2=$((counter2+1))
	done 
counter1=$((counter1+1))
done 

counter1=1
for i in /crex/proj/snic2021-23-717/private/trimmed/klad8/*_1*_paired*
do
        counter2=1
        for j in /crex/proj/snic2021-23-717/private/trimmed/klad8/*_2*_paired*
        do
                if [[ $counter1 -eq $counter2 ]]
                then
			basename=$(basename $i)
                        if [[ ${basename} =~ $regex ]]
                        then
                                basename=${BASH_REMATCH[*]}
                        fi

                        if [[ ! -d /crex/proj/snic2021-23-717/private/assembly/$basename ]]
                        then
                                mkdir /crex/proj/snic2021-23-717/private/assembly/$basename
                        fi

                        echo "spades.py -1 $i -2 $j -m 50 --careful -o /crex/proj/snic2021-23-717/private/assembly/$basename" > spades_script.sh
                        bash spades_script.sh
                fi
                counter2=$((counter2+1))
        done
counter1=$((counter1+1))
done
