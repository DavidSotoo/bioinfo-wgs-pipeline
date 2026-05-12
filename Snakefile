rule trim_reads:
    input:
        r1 = "data/fastq/{sample}_R1.fq.gz",
        r2 = "data/fastq/{sample}_R2.fq.gz"
    output:
        r1_paired = "results/trimmed/{sample}_R1.fq.gz",
        r1_unpaired = "results/trimmed/{sample}_R1_unpaired.fq.gz",
        r2_paired = "results/trimmed/{sample}_R2.fq.gz",
        r2_unpaired = "results/trimmed/{sample}_R2_unpaired.fq.gz"
    log:
        "results/logs/trimmomatic/{sample}.log"
    shell:
        """
        trimmomatic PE {input.r1} {input.r2} \
        {output.r1_paired} {output.r1_unpaired} \
        {output.r2_paired} {output.r2_unpaired} \
        ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10 \
        LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 > {log} 2>&1
        """


rule bwa_index:
    input:
        "resources/genome.fasta"
    output:
        "resources/genome.fasta.bwt"
    shell:
        "bwa index {input}"


rule bwa_map:
    input:
        genome = "resources/genome.fasta",
        index = "resources/genome.fasta.bwt",
        r1 = "results/trimmed/{sample}_R1.fq.gz",
        r2 = "results/trimmed/{sample}_R2.fq.gz"
    output:
        "results/bam/{sample}.bam"
    shell:
        "bwa mem {input.genome} {input.r1} {input.r2} | samtools view -Sb - > {output}"
