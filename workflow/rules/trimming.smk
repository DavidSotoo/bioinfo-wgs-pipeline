rule trim_reads:
    input:
        r1=fastq_r1,
        r2=fastq_r2
    output:
        r1="results/trimmed/{unit}_R1.trimmed.fastq.gz",
        r2="results/trimmed/{unit}_R2.trimmed.fastq.gz",
        html="results/trimmed/{unit}.fastp.html",
        json="results/trimmed/{unit}.fastp.json"
    log:
        "results/logs/fastp/{unit}.log"
    benchmark:
        "results/benchmarks/fastp/{unit}.txt"
    threads: config["threads"]["trimming"]
    params:
        qualified_quality_phred=config["trimming"]["qualified_quality_phred"],
        length_required=config["trimming"]["length_required"],
        detect_adapter="--detect_adapter_for_pe" if config["trimming"]["detect_adapter_for_pe"] else ""
    conda:
        "../../envs/trimming.yaml"
    shell:
        """
        mkdir -p results/trimmed results/logs/fastp results/benchmarks/fastp
        fastp \
          --in1 {input.r1} --in2 {input.r2} \
          --out1 {output.r1} --out2 {output.r2} \
          --thread {threads} \
          --qualified_quality_phred {params.qualified_quality_phred} \
          --length_required {params.length_required} \
          {params.detect_adapter} \
          --html {output.html} --json {output.json} \
          > {log} 2>&1
        """
