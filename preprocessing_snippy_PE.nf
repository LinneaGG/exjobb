//Nextflow pipeline for subsampling & trimming paired reads + running Snippy

/*
I had two groups of reads with two different naming schemes, and only one of these groups had files which needed to be subsampled, 
which is why some of the reads are only added to the pipeline after the subsampling. 
*/

//Divide paired reads that may need to be subsampled
to_be_subsampled1 = Channel.fromPath('/path/to/reads/*_1.fastq.gz')
to_be_subsampled2 = Channel.fromPath('/path/to/reads/*_2.fastq.gz')

//The reads that don't need to be subsampled
miseqChannel1=Channel.fromPath('/path/to/reads/*_R1_*') 
miseqChannel2=Channel.fromPath('/path/to/reads/*_R2_*')

refChannel=Channel.fromPath('/path/to/reference/TW14359.fasta') //Path to your reference

trimmed_outdir = '/path/to/trimmed_outdir/'
snippy_outdir = '/path/to/snippy_outdir/'


process subsample { //Subsampling reads with > 100x coverage, skip straight to trimming if subsampling is not needed

input:
each i from to_be_subsampled1
each j from to_be_subsampled2

output:
file '*' optional true into subsampleChannel

shell:
'''
regex="[^_]*" #Keeps only the part before the first _ of the file name, may need to be changed depending on the IDs
basename1=$(basename "!{i}" .fastq.gz)
if [[ ${basename1} =~ $regex ]]
then
	bn1=${BASH_REMATCH[*]}
fi
basename2=$(basename "!{j}" .fastq.gz)
if [[ ${basename2} =~ $regex ]]
then
	bn2=${BASH_REMATCH[*]}
fi

if [[ ${bn1} == ${bn2} ]] #Checking if IDs of R1 & R2 are identical
then
        lines=$(zcat !{i} | wc -l)
        seqs=$(expr $lines / 4)
        if [ $seqs -gt 4000000 ] #Number depends on read length, this is for 100 bp
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

process zip { //Zip files again after subsampling

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

//Add the reads that were not subsampled to the same channel as the subsampled reads
readsChannel1=zippedChannel1.mix(miseqChannel1)
readsChannel2=zippedChannel2.mix(miseqChannel2)

process trimming { 

input:
each i from readsChannel1
each j from readsChannel2

output:
file '*_paired.trimmed.fastq.gz' optional true into trimmedChannel

//Remove if you don't want to save the trimmed reads in a directory
publishDir (
path: trimmed_outdir,
mode: 'link',
) 

shell:
'''
regex="[^_]*" #Keeps only the part before the first _ of the file name, may need to be changed depending on the IDs
basename1=$(basename "!{i}" .fastq.gz)
if [[ ${basename1} =~ $regex ]]
then
	bn1=${BASH_REMATCH[*]}
fi
basename2=$(basename "!{j}" .fastq.gz)
if [[ ${basename2} =~ $regex ]]
then
	bn2=${BASH_REMATCH[*]}
fi
if [[ ${bn1} == ${bn2} ]] 
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
regex="[^_]*" #Keeps only the part before the first _ of the file name, may need to be changed depending on the IDs
basename1=$(basename "!{i}" .fastq.gz)
if [[ ${basename1} =~ $regex ]]
then
	bn1=${BASH_REMATCH[*]}
fi
basename2=$(basename "!{j}" .fastq.gz)
if [[ ${basename2} =~ $regex ]]
then
	bn2=${BASH_REMATCH[*]}
fi

if [[ ${bn1} == ${bn2} ]] 
then
	ID=${bn1}
	echo "${ID}\t!{i}\t!{j}" >> file.tab
fi

'''
}

fileChannel=outChannel.collectFile(name: 'snippyfile.tab', newLine: false)

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

publishDir (
path: snippy_outdir,
mode: 'link',
) 

shell:
'''
bash !{script}
'''

}

