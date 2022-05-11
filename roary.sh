#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH -J roary

module load bioinfo-tools
module load Roary

roary -v -f /crex/proj/snic2021-23-717/private/roary/ -i 90 /crex/proj/snic2021-23-717/private/prokka/*/*.gff 

