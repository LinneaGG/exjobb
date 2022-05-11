#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 12:00:00
#SBATCH -J prep_snippy_human

module load bioinfo-tools
module load Nextflow
module load seqtk
module load trimmomatic
module load snippy

nextflow prep_snippy_human.nf #-resume

