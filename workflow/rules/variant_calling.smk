rule call_variants:
    input:
        ref=REF,
        fai=rules.samtools_faidx.output,
        bams=expand("results/alignment/samples/{sample}.dedup.bam", sample=SAMPLES),
        bais=expand("results/alignment/samples/{sample}.dedup.bam.bai", sample=SAMPLES)
    output:
        vcf="results/variants/cohort.raw.vcf.gz",
        tbi="results/variants/cohort.raw.vcf.gz.tbi"
    log:
        "results/logs/variant_calling/bcftools.log"
    benchmark:
        "results/benchmarks/variant_calling/bcftools.txt"
    threads: config["threads"]["variant_calling"]
    params:
        min_base_quality=config["variant_calling"]["min_base_quality"],
        ploidy=config["variant_calling"]["ploidy"]
    conda:
        "../../envs/variant_calling.yaml"
    shell:
        """
        mkdir -p results/variants results/logs/variant_calling results/benchmarks/variant_calling
        bcftools mpileup \
          --threads {threads} \
          --fasta-ref {input.ref} \
          --min-BQ {params.min_base_quality} \
          --annotate FORMAT/DP,FORMAT/AD \
          {input.bams} 2> {log} \
          | bcftools call --threads {threads} --multiallelic-caller --variants-only --ploidy {params.ploidy} -Oz -o {output.vcf}
        tabix -p vcf {output.vcf}
        """
