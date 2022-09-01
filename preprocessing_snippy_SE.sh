#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 12:00:00
#SBATCH -J prep_snippy_SE

module load bioinfo-tools
module load Nextflow
module load seqtk
module load trimmomatic
module load snippy

nextflow preprocessing_snippy_SE.nf #-resume

