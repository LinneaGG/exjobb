//Divide paired reads
to_be_subsampled1 = Channel.fromPath('/home/linne/exjobb/data/klad8/*_1.fastq.gz')
to_be_subsampled2 = Channel.fromPath('/home/linne/exjobb/data/klad8/*_2.fastq.gz')

process subsample {

input:
each i from to_be_subsampled1
each j from to_be_subsampled2

output:
file '*' optional true into subsampleChannel

shell:
'''
basename1=$(basename "!{i}" .fastq.gz)
basename2=$(basename "!{j}" .fastq.gz)

lines=$(zcat !{i} | wc -l)
seqs=$(expr $lines / 4)

if [[ ${basename1:0:11} == ${basename2:0:11} ]]
then
        lines=$(zcat !{i} | wc -l)
        seqs=$(expr $lines / 4)
        if [ $seqs -gt 4000000 ] #Depends on read length 
        then
                seqtk sample -s100 !{i} 4000000 > ${basename1}_subsample.fastq
                seqtk sample -s100 !{j} 4000000 > ${basename2}_subsample.fastq
        else
                zcat !{i} > ${basename1}.fastq
                zcat !{j} > ${basename2}.fastq
        fi
fi
'''
}

process zip {

input:
each subsample from subsampleChannel.flatten()

output:
file '*' into zippedChannel

shell:
'''
basename=$(basename "!{subsample}" .fastq)
gzip -c !{subsample} > $basename.fastq.gz
'''
}

zippedChannel.into{ zippedChannelCopy1; zippedChannelCopy2 }

zippedChannel1=zippedChannelCopy1.filter( ~/.*_1.*/ )
zippedChannel2=zippedChannelCopy2.filter( ~/.*_2.*/ )

miseqChannel1=Channel.fromPath('/home/linne/exjobb/data/klad8/*_R1_*')
miseqChannel2=Channel.fromPath('/home/linne/exjobb/data/klad8/*_R2_*')

readsChannel1=zippedChannel1.mix(miseqChannel1)
readsChannel2=zippedChannel2.mix(miseqChannel2)

process trimming { 

input:
each i from readsChannel1
each j from readsChannel2

output:
file '*_paired.trimmed.fastq.gz' optional true into trimmedChannel

publishDir '/crex/proj/snic2021-23-717/private/trimmed/', mode: 'link'

shell:
'''
basename1=$(basename "!{i}" .fastq.gz)
basename2=$(basename "!{j}" .fastq.gz)
if [[ ${basename1:0:11} == ${basename2:0:11} ]]
then
	java -jar $TRIMMOMATIC_ROOT/trimmomatic-0.39.jar PE !{i} !{j} ${basename1}_paired.trimmed.fastq.gz ${basename1}_unpaired.trimmed.fastq.gz \
        ${basename2}_paired.trimmed.fastq.gz ${basename2}_unpaired.trimmed.fastq.gz \
        ILLUMINACLIP:$TRIMMOMATIC_ROOT/adapters/NexteraPE-PE.fa:2:30:10:2:True LEADING:3 TRAILING:20 MINLEN:36
fi
'''
}

flatChannel=trimmedChannel.flatten()

flatChannel.into{ trimmedChannel1; trimmedChannel2 }

R1Channel=trimmedChannel1.filter( ~/.*_R1_.*|.*_1_.*/ )
R2Channel=trimmedChannel2.filter( ~/.*_R2_.*|.*_2_.*/ )

process createTabFile {

input:
each i from R1Channel
each j from R2Channel

output:
file '*' optional true into outChannel

shell:
'''
regex="[^_]*"
basename1=$(basename "!{i}" .fastq.gz)
basename2=$(basename "!{j}" .fastq.gz)
if [[ ${basename1:0:11} == ${basename2:0:11} ]]

then
        if [[ ${basename1} =~ $regex ]]
        then
                ID=${BASH_REMATCH[*]}
                echo "${ID}\t!{i}\t!{j}" >> file.tab
        fi
fi

'''
}

fileChannel=outChannel.collectFile(name: 'snippyfile.tab', newLine: false)
refChannel=Channel.fromPath('/home/linne/exjobb/snp_analysis/TW14359.fasta')

process createSnippyScript {

input:
file tabfile from fileChannel
val ref from refChannel

output:
file '*' into scriptChannel

shell:
'''
snippy-multi !{tabfile} --ref !{ref} --cpus 16 --minfrac 0.9 > snippy_multi.sh
'''
}

process runSnippy {

time '4h'
executor 'slurm'
clusterOptions '-A snic2021-22-997 -p core -n 16 -J run_snippy'

input:
file script from scriptChannel

output:
file '*' into snippy_out

publishDir '/crex/proj/snic2021-23-717/private/snp_analysis/', mode: 'link'

shell:
'''
bash !{script}
'''

}

