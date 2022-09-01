for f in /path/to/assemblies/*/contigs.fasta
do

        id=$(basename $(dirname $f))

        awk 'BEGIN{FS="_";x=0;};{if ($4>=500 && $6>=1 && $0~/>/) x=1; else if ($0~/>/) x=0; if (x==1) print $0;}' ${f} > /path/to/filtered_assemblies_outdir/${id}_filtered.fasta

done
