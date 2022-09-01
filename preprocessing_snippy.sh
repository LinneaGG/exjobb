#!/bin/bash -l
#SBATCH -A snic2021-22-997
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 15:00:00
#SBATCH -J preprocessing_snippy

module load bioinfo-tools
module load Nextflow
module load seqtk
module load trimmomatic
module load snippy

nextflow preprocessing_snippy_PE.nf #-resume

