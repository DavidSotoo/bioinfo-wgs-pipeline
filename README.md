# WGS Pipeline con Snakemake

Pipeline reproducible de Whole Genome Sequencing inspirado en el flujo `non-model-wgs-example-data`: FASTQ con nombres desordenados, symlinks limpios, `samples.tsv`, `units.tsv`, QC, trimming, alineamiento, BAM por unidad, BAM fusionado por muestra, variant calling, filtrado, MultiQC y DAG.

El proyecto está pensado para Linux/WSL Ubuntu. Incluye un generador de datos mini compatibles con la estructura del ejemplo para que el workflow corra rápido.

## Estructura

```text
wgs-pipeline/
├── workflow/
│   ├── Snakefile
│   └── rules/
│       ├── qc.smk
│       ├── trimming.smk
│       ├── alignment.smk
│       ├── variant_calling.smk
│       └── filtering.smk
├── config/config.yaml
├── data/messy_names/fastqs/
├── fastq/
├── resources/genome.fasta
├── samples.tsv
├── units.tsv
├── results/
├── envs/
├── scripts/
│   ├── check_inputs.py
│   ├── create_test_fastqs.sh
│   └── summarize_variants.py
├── Snakefile
├── setup.sh
├── .gitignore
└── README.md
```

## Dataset

Las muestras biológicas están en `samples.tsv`:

```text
s001 s002 s003 s004 s005 s006 s007 s008
```

Las unidades técnicas/lane-runs están en `units.tsv`, por ejemplo:

```text
s001---1
s002---1
s002---2
s003---1
...
s008---3
```

Cada unidad apunta a:

```text
fastq/<unit>_R1.fq.gz
fastq/<unit>_R2.fq.gz
```

Estos archivos son symlinks hacia:

```text
data/messy_names/fastqs/T199967_T2087_HY75HDSX2_L001_R1_001.fastq.gz
data/messy_names/fastqs/T199967_T2087_HY75HDSX2_L001_R2_001.fastq.gz
...
```

Genera los FASTQ mini y symlinks con:

```bash
bash scripts/create_test_fastqs.sh
```

## Instalación

En Ubuntu/WSL:

```bash
sudo apt update
sudo apt install -y git wget bzip2 graphviz gzip
```

Instala Miniconda/Mambaforge si no tienes Conda. Después:

```bash
cd wgs-pipeline
bash setup.sh
conda activate wgs-pipeline
```

`setup.sh` crea el ambiente base de Snakemake y ejecuta `scripts/create_test_fastqs.sh`.

## Ejecución

Validar inputs:

```bash
python scripts/check_inputs.py
```

Dry-run:

```bash
snakemake -np --use-conda
```

Ejecución completa:

```bash
snakemake --cores 4 --use-conda
```

Generar DAG:

```bash
snakemake --cores 1 --use-conda results/dag/dag.png
```

Comando DAG directo:

```bash
snakemake --dag | dot -Tpng > dag.png
```

## Workflow

El workflow usa `units.tsv` como fuente de verdad:

1. `fastqc_raw`: FastQC por unidad y read.
2. `trim_reads`: fastp por unidad paired-end.
3. `fastqc_trimmed`: FastQC post-trimming.
4. `bwa_index` y `samtools_faidx`: indexado de referencia.
5. `align_unit`: BWA MEM por unidad técnica.
6. `merge_sample_bams`: fusión de unidades por muestra biológica.
7. `index_bam`: índice BAI por muestra.
8. `samtools_stats`: métricas BAM.
9. `call_variants`: VCF multi-muestra con BCFtools.
10. `filter_variants`: filtrado por QUAL y DP.
11. `summarize_variants`: resumen TSV.
12. `multiqc`: reporte HTML integrado.
13. `dag`: grafo PNG del workflow.

## Outputs

```text
results/qc/raw/                         FastQC crudo por unidad
results/qc/trimmed/                     FastQC post-trimming por unidad
results/qc/multiqc/multiqc_report.html  Reporte MultiQC
results/trimmed/                        FASTQ recortados + reportes fastp
results/alignment/units/                BAM ordenado por unidad técnica
results/alignment/samples/              BAM fusionado por muestra
results/alignment/stats/                SAMtools stats
results/variants/cohort.raw.vcf.gz      VCF crudo multi-muestra
results/variants/cohort.filtered.vcf.gz VCF filtrado
results/reports/variant_summary.tsv     Resumen tabular
results/dag/dag.png                     DAG del workflow
results/logs/                           Logs
results/benchmarks/                     Benchmarks
```

```bash
git config --global --add safe.directory "$(pwd)"
```

## Troubleshooting

Faltan FASTQ:

```bash
bash scripts/create_test_fastqs.sh
python scripts/check_inputs.py
```

`snakemake: command not found`:

```bash
conda activate wgs-pipeline
```

Graphviz no genera PNG:

```bash
sudo apt install -y graphviz
```

Bloqueo de Snakemake:

```bash
snakemake --unlock
```

Recrear ambientes Conda:

```bash
snakemake --cores 4 --use-conda --conda-cleanup-envs
```
