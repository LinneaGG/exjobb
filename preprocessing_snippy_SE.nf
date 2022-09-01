//Nextflow pipeline for trimming single-end reads + running snippy

fileChannel=Channel.fromPath('/path/to/reads/*.fastq.gz')

process trimming { 

input:
file i from fileChannel

output:
file '*' optional true into trimmedChannel

publishDir '/path/to/trimmed_outdir/', mode: 'link' //Remove if you don't want to save the trimmed reads in a directory

shell:
'''
basename=$(basename "!{i}" .fastq.gz)

java -jar $TRIMMOMATIC_ROOT/trimmomatic-0.39.jar SE -phred33 !{i} ${basename}.trimmed.fastq.gz ILLUMINACLIP:$TRIMMOMATIC_ROOT/adapters/NexteraPE-PE.fa:2:30:10 \
LEADING:3 TRAILING:20 SLIDINGWINDOW:4:15 MINLEN:36
'''
}

process createTabFile {

input:
each i from trimmedChannel

output:
file '*' optional true into outChannel

shell:
'''
basename=$(basename "!{i}" .trimmed.fastq.gz)
echo "${basename}\t!{i}" >> file.tab

'''
}

fileChannel=outChannel.collectFile(name: 'snippyfile.tab', newLine: false)
refChannel=Channel.fromPath('/path/to/reference/TW14359.fasta')

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

publishDir '/path/to/snippy_outdir/', mode: 'link'

shell:
'''
bash !{script}
'''

}

