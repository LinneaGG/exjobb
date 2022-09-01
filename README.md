# Genomic comparison of Shiga toxin-producing _E. coli_ from ruminants and humans
This project ... (abstract?)
## Running the analyses
To run these analyses you will need:
* Fastq files, paired- or single-end
* A reference for the serotype tested
* Metadata (csv file of traits you want to test)
### Pre-processing & phylogenetic analysis
1. Run `qc.sh` to quality check to see if the data need to be subsampled and what adapters are present and edit the preprocessing_snippy script accordingly if needed
