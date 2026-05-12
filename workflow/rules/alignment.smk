rule bwa_index:
    input:
        REF
    output:
        amb=REF + ".amb",
        ann=REF + ".ann",
        bwt=REF + ".bwt",
        pac=REF + ".pac",
        sa=REF + ".sa"
    log:
        "results/logs/reference/bwa_index.log"
    benchmark:
        "results/benchmarks/reference/bwa_index.txt"
    conda:
        "../../envs/alignment.yaml"
    shell:
        """
        mkdir -p results/logs/reference results/benchmarks/reference
        bwa index {input} > {log} 2>&1
        """

rule samtools_faidx:
    input:
        REF
    output:
        REF + ".fai"
    log:
        "results/logs/reference/faidx.log"
    benchmark:
        "results/benchmarks/reference/faidx.txt"
    conda:
        "../../envs/alignment.yaml"
    shell:
        """
        mkdir -p results/logs/reference results/benchmarks/reference
        samtools faidx {input} > {log} 2>&1
        """

rule align_unit:
    input:
        r1="results/trimmed/{unit}_R1.trimmed.fastq.gz",
        r2="results/trimmed/{unit}_R2.trimmed.fastq.gz",
        idx=rules.bwa_index.output
    output:
        "results/alignment/units/{unit}.sorted.bam"
    log:
        "results/logs/alignment/units/{unit}.log"
    benchmark:
        "results/benchmarks/alignment/units/{unit}.txt"
    threads: config["threads"]["alignment"]
    params:
        reference=REF,
        rg=lambda wildcards: f"@RG\\tID:{wildcards.unit}\\tSM:{UNIT_TO_SAMPLE[wildcards.unit]}\\tPL:ILLUMINA\\tLB:non-model-wgs"
    conda:
        "../../envs/alignment.yaml"
    shell:
        """
        mkdir -p results/alignment/units results/logs/alignment/units results/benchmarks/alignment/units
        bwa mem -t {threads} -R "{params.rg}" {params.reference} {input.r1} {input.r2} 2> {log} \
          | samtools view -@ {threads} -b - \
          | samtools sort -@ {threads} -o {output} -
        """

rule merge_sample_bams:
    input:
        unit_bams_for_sample
    output:
        "results/alignment/samples/{sample}.sorted.bam"
    log:
        "results/logs/alignment/samples/{sample}.merge.log"
    benchmark:
        "results/benchmarks/alignment/samples/{sample}.merge.txt"
    threads: config["threads"]["samtools"]
    conda:
        "../../envs/alignment.yaml"
    shell:
        """
        mkdir -p results/alignment/samples results/logs/alignment/samples results/benchmarks/alignment/samples
        samtools merge -@ {threads} -f {output} {input} > {log} 2>&1
        """

rule index_bam:
    input:
        "results/alignment/samples/{sample}.sorted.bam"
    output:
        "results/alignment/samples/{sample}.sorted.bam.bai"
    log:
        "results/logs/alignment/samples/{sample}.index.log"
    benchmark:
        "results/benchmarks/alignment/samples/{sample}.index.txt"
    threads: config["threads"]["samtools"]
    conda:
        "../../envs/alignment.yaml"
    shell:
        """
        samtools index -@ {threads} {input} > {log} 2>&1
        """

rule samtools_stats:
    input:
        bam="results/alignment/samples/{sample}.sorted.bam",
        bai="results/alignment/samples/{sample}.sorted.bam.bai"
    output:
        "results/alignment/stats/{sample}.samtools.stats.txt"
    log:
        "results/logs/alignment/samples/{sample}.stats.log"
    benchmark:
        "results/benchmarks/alignment/samples/{sample}.stats.txt"
    conda:
        "../../envs/alignment.yaml"
    shell:
        """
        mkdir -p results/alignment/stats
        samtools stats {input.bam} > {output} 2> {log}
        """
