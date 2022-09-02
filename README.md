# Genomic comparison of Shiga toxin-producing _E. coli_ from ruminants and humans
In this study, the aim is to identify any genomic differences between Swedish STEC isolates that have caused HUS and isolates that did not, as well as between isolates taken from animals and isolates taken from humans. 
## Running the analyses
To run these analyses you will need:
* Fastq files, paired- or single-end
* A reference for the serotype tested
* Metadata (csv file of traits you want to compare)

GenBank accession numbers of references used: 

O157:H7 - CP001368

O26:H11 -  CP058682.2

O121:H19 - CP022407.1


Note that some of the scripts (`preprocessing_snippy.nf` and `spades.sh`) use a regex to keep only the part before the first "_" in the file name as the ID of the sample, so depending on how your files are named this may need to be edited. 

### Pre-processing & phylogenetic analysis
1. Run `qc.sh` to quality check to see if the data need to be subsampled and what adapters are present and edit the `preprocessing_snippy.nf` script accordingly if needed
2. Run `preprocessing_snippy_PE.sh` or `preprocessing_snippy_SE.sh` depending on if you have paired- or single-end files. If you only want to trim without running Snippy just remove the last processes from the script. 
3. Run `grapetree_nj.sh` to generate phylogenetic tree from your alignment
4. Visualise tree using Grapetree: https://achtman-lab.github.io/GrapeTree/MSTree_holder.html 
### Pan-genome analysis
1. Run `spades_PE.sh` or `spades_SE.sh` depending on if you have paired- or singe end files. 
2. Run `filter_contigs.sh` to remove short contigs
3. Run `quast.sh` to check the quality of the assemblies
4. Run `prokka.sh` to annotate 
5. Run `roary.sh` to obtain 'gene_presence_absence' file
### Statistical analysis
Use the gene_presence_absence.Rtab file and your traits.csv file to run `stat_analysis.R` in Rstudio. 

Or, use the gene_presence_absence.csv file and your traits.csv file to run `scoary.sh`. 
