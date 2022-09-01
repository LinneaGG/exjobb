path_to_assemblies="/path/to/assemblies"
path_to_filtered_assembly_outdir="/path/to/filtered_assembly_outdir"

for f in ${path_to_assemblies}/*/contigs.fasta
do

        id=$(basename $(dirname $f))

        awk 'BEGIN{FS="_";x=0;};{if ($4>=500 && $6>=1 && $0~/>/) x=1; else if ($0~/>/) x=0; if (x==1) print $0;}' ${f} > ${path_to_filtered_assembly_outdir}/${id}_filtered.fasta

done
