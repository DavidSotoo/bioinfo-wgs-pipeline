#!/usr/bin/env bash
set -euo pipefail

mkdir -p data/messy_names/fastqs fastq resources

cat > resources/genome.fasta <<'FASTA'
>chrMini
GATCTAGCTAGGCTAACCGTTAGCACGATCGTACCGGTAACCTGATCGATCGTACGATGCTAGCTTACGATCGTAGCTAGCATCGGATCGATCGTACCTAGGCTAACGTA
FASTA

write_pair() {
  local unit="$1"
  local messy_prefix="$2"
  local variant_base="$3"
  local r1="data/messy_names/fastqs/${messy_prefix}_R1_001.fastq.gz"
  local r2="data/messy_names/fastqs/${messy_prefix}_R2_001.fastq.gz"
  local seq1="GATCTAGCTAGGCTAACCGTTAGCACGATCGTACCGGTAACCTGATCGA"
  local seq2="AGCTAGCATCGGATCGATCGTACCTAGGCTAACGTATACGATGCTAGCTA"

  if [[ "${variant_base}" == "alt1" ]]; then
    seq1="GATCTAGCTAGGCTAACCGTTAGTACGATCGTACCGGTAACCTGATCGA"
  elif [[ "${variant_base}" == "alt2" ]]; then
    seq2="AGCTAGCATCGGATCGATCGTACCTAGGCTAACGTATACGATGCTAGTTA"
  fi

  {
    printf '@%s_read1/1\n%s\n+\n%s\n' "${unit}" "${seq1}" "$(printf 'I%.0s' $(seq 1 ${#seq1}))"
    printf '@%s_read2/1\nTAGGCTAACCGTTAGCACGATCGTACCGGTAACCTGATCGATCGTACGAT\n+\nIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII\n' "${unit}"
  } | gzip -c > "${r1}"

  {
    printf '@%s_read1/2\n%s\n+\n%s\n' "${unit}" "${seq2}" "$(printf 'I%.0s' $(seq 1 ${#seq2}))"
    printf '@%s_read2/2\nTCGATCGTACCTAGGCTAACGTATACGATGCTAGCTAGCATCGGATCGA\n+\nIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII\n' "${unit}"
  } | gzip -c > "${r2}"

  ln -sfn "../${r1}" "fastq/${unit}_R1.fq.gz"
  ln -sfn "../${r2}" "fastq/${unit}_R2.fq.gz"
}

write_pair s001---1 T199967_T2087_HY75HDSX2_L001 ref
write_pair s002---1 T199968_T2087_HY75HDSX2_L001 alt1
write_pair s002---2 T199968_T2087_HY75HDSX2_L002 alt1
write_pair s003---1 T199969_T2087_HY75HDSX2_L002 ref
write_pair s003---2 T199969_T2087_HY75HDSX2_L003 ref
write_pair s003---3 T199969_T2087_HTYYCBBXX_L002 ref
write_pair s004---1 T199970_T2087_HY75HDSX2_L003 alt2
write_pair s004---2 T199970_T2094_HY75HDSX2_L004 alt2
write_pair s005---1 T199971_T2087_HY75HDSX2_L002 ref
write_pair s005---2 T199971_T2087_HY75HDSX2_L004 ref
write_pair s005---3 T199971_T2099_HTYYCBBXX_L002 alt1
write_pair s006---1 T199972_T2087_HY75HDSX2_L001 alt1
write_pair s006---2 T199972_T2087_HTYYCBBXX_L003 alt1
write_pair s006---3 T199972_T2094_HY75HDSX2_L002 alt2
write_pair s006---4 T199972_T2094_HTYYCBBXX_L004 alt2
write_pair s007---1 T199973_T2087_HY75HDSX2_L002 ref
write_pair s007---2 T199973_T2087_HY75HDSX2_L003 ref
write_pair s007---3 T199973_T2094_HY75HDSX2_L002 alt2
write_pair s007---4 T199973_T2094_HY75HDSX2_L003 alt2
write_pair s008---1 T199974_T2087_HY75HDSX2_L001 alt1
write_pair s008---2 T199974_T2094_HY75HDSX2_L001 alt1
write_pair s008---3 T199974_T2099_HY75HDSX2_L001 alt1

echo "Created non-model-wgs-example-data compatible test FASTQs and clean symlinks."
