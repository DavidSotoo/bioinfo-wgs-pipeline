rule fastqc_raw:
    input:
        lambda wildcards: UNIT_TO_FQ1[wildcards.unit] if wildcards.read == "R1" else UNIT_TO_FQ2[wildcards.unit]
    output:
        html="results/qc/raw/{unit}_{read}_fastqc.html",
        zip="results/qc/raw/{unit}_{read}_fastqc.zip"
    log:
        "results/logs/fastqc/raw/{unit}_{read}.log"
    benchmark:
        "results/benchmarks/fastqc_raw/{unit}_{read}.txt"
    threads: config["threads"]["fastqc"]
    conda:
        "../../envs/qc.yaml"
    shell:
        """
        mkdir -p results/qc/raw results/logs/fastqc/raw results/benchmarks/fastqc_raw
        fastqc --threads {threads} --outdir results/qc/raw {input} > {log} 2>&1
        """

rule fastqc_trimmed:
    input:
        "results/trimmed/{unit}_{read}.trimmed.fastq.gz"
    output:
        html="results/qc/trimmed/{unit}_{read}.trimmed_fastqc.html",
        zip="results/qc/trimmed/{unit}_{read}.trimmed_fastqc.zip"
    log:
        "results/logs/fastqc/trimmed/{unit}_{read}.log"
    benchmark:
        "results/benchmarks/fastqc_trimmed/{unit}_{read}.txt"
    threads: config["threads"]["fastqc"]
    conda:
        "../../envs/qc.yaml"
    shell:
        """
        mkdir -p results/qc/trimmed results/logs/fastqc/trimmed results/benchmarks/fastqc_trimmed
        fastqc --threads {threads} --outdir results/qc/trimmed {input} > {log} 2>&1
        """

rule multiqc:
    input:
        raw=expand("results/qc/raw/{unit}_{read}_fastqc.zip", unit=UNITS, read=["R1", "R2"]),
        trimmed=expand("results/qc/trimmed/{unit}_{read}.trimmed_fastqc.zip", unit=UNITS, read=["R1", "R2"]),
        fastp=expand("results/trimmed/{unit}.fastp.html", unit=UNITS),
        stats=expand("results/alignment/stats/{sample}.samtools.stats.txt", sample=SAMPLES)
    output:
        "results/qc/multiqc/multiqc_report.html"
    log:
        "results/logs/multiqc.log"
    benchmark:
        "results/benchmarks/multiqc.txt"
    conda:
        "../../envs/qc.yaml"
    shell:
        """
        mkdir -p results/qc/multiqc results/logs results/benchmarks
        multiqc results --outdir results/qc/multiqc --force > {log} 2>&1
        """

rule dag:
    output:
        "results/dag/dag.png"
    log:
        "results/logs/dag.log"
    conda:
        "../../envs/snakemake.yaml"
    shell:
        """
        mkdir -p results/dag results/logs
        snakemake --snakefile Snakefile --configfile config/config.yaml --nolock --dag \
          | dot -Tpng > {output} 2> {log}
        """
