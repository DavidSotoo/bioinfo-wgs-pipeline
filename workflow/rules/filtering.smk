rule filter_variants:
    input:
        vcf="results/variants/cohort.raw.vcf.gz",
        tbi="results/variants/cohort.raw.vcf.gz.tbi"
    output:
        vcf="results/variants/cohort.filtered.vcf.gz",
        tbi="results/variants/cohort.filtered.vcf.gz.tbi"
    log:
        "results/logs/filtering/bcftools_filter.log"
    benchmark:
        "results/benchmarks/filtering/bcftools_filter.txt"
    params:
        min_qual=config["filtering"]["min_qual"],
        min_depth=config["filtering"]["min_depth"]
    conda:
        "../../envs/variant_calling.yaml"
    shell:
        """
        mkdir -p results/logs/filtering results/benchmarks/filtering
        bcftools filter \
          --include 'QUAL>={params.min_qual} && INFO/DP>={params.min_depth}' \
          --output-type z \
          --output {output.vcf} \
          {input.vcf} > {log} 2>&1
        tabix -p vcf {output.vcf}
        """

rule summarize_variants:
    input:
        "results/variants/cohort.filtered.vcf.gz"
    output:
        "results/reports/variant_summary.tsv"
    log:
        "results/logs/reports/variant_summary.log"
    benchmark:
        "results/benchmarks/reports/variant_summary.txt"
    conda:
        "../../envs/reporting.yaml"
    shell:
        """
        mkdir -p results/reports results/logs/reports results/benchmarks/reports
        python scripts/summarize_variants.py {input} {output} > {log} 2>&1
        """
