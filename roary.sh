#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH -J roary

module load bioinfo-tools
module load Roary

path_to_roary_outdir="/path/to/roary_outdir/" #make sure to end path with /
path_to_prokka_outdir="/path/to/prokka"

roary -v -f ${path_to_roary_outdir} -i 90 ${path_to_prokka_outdir}/*/*.gff 

