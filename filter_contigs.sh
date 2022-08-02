for f in /crex/proj/snic2021-23-717/private/exjobb/assembly/human/*/contigs.fasta
do

        id=$(basename $(dirname $f))

        awk 'BEGIN{FS="_";x=0;};{if ($4>=500 && $6>=1 && $0~/>/) x=1; else if ($0~/>/) x=0; if (x==1) print $0;}' ${f} > /crex/proj/snic2021-23-717/private/exjobb/filtered_assembly/human/${id}_filtered.fasta

done
