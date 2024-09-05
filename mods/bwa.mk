#
# Generate alignments with bwa mem
#

# Reference genome.
REF ?= refs/genome.fa

# Directory for storing the index.
IDX_DIR ?= $(dir ${REF})/idx

# Root name of the index.
IDX ?= ${IDX_DIR}/$(notdir ${REF})

# A file in the index directory.
IDX_FILE ?= ${IDX}.ann

# Number of CPU cores.
CORES ?= 4

# Additional flags to pass to BWA.
BWA_FLAGS ?= -t ${CORES}

# Sam filter flags for filtering the BAM file before sorting.
SAM_FLAGS ?=

# First in pair.
R1 ?= reads/reads1.fq

# Second in pair. If undefined, BWA runs in single end mode.
R2 ?=

# The alignment file.
BAM ?= bam/aln.bam

# Unsorted BAM file.
BAM_TMP = $(basename ${BAM}).unsorted.bam

# Set the values for the read group.
ID ?= run1
SM ?= sample1
LB ?= library1
PL ?= ILLUMINA

# Build the read groups tag.
RG = '@RG\tID:${ID}\tSM:${SM}\tLB:${LB}\tPL:${PL}'

# Makefile customizations.
.DELETE_ON_ERROR:
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables --no-print-directory

# Print usage information.
usage:
	@echo ""
	@echo "BWA module - align reads using BWA"
	@echo ""
	@echo "Usage:   make -f ~/workflows/run/bwa.mk <command>"
	@echo ""
	@echo "Command: index - generate bwa index"
	@echo "         align - align raw reads to reference genome"
	@echo "         stats - generate alignment statistics"
	@echo ""

# Read 1 must exist.
${R1}:
	@echo "# Read 1 file not found: R1=${R1}"
	@exit -1

# If R2 is set, it must exist.
ifneq (${R2},)
${R2}:
	@echo "# Read 2 file not found: R2=${R2}"
	@exit -1
endif

# Exit if reference is not found.
${REF}:
	echo "# Reference not found: ${REF}";
	exit -1

# Index the reference genome.
${IDX_FILE}: ${REF}
	@mkdir -p $(dir $@)
	bwa index -p ${IDX} ${REF}

# Create the index.
index: ${IDX_FILE}
	@echo "# bwa index: ${IDX}"

# Remove the index.
index!:
	rm -rf ${IDX_FILE}

# Pair end alignment.
${BAM_TMP}: ${R1} ${R2}
	@if [ ! -f ${IDX_FILE} ]; then
		echo "# bwa index not found: IDX=${IDX}";
		exit -1
	fi
	mkdir -p $(dir $@)
	bwa mem ${BWA_FLAGS} -R ${RG} ${IDX} ${R1} ${R2} | samtools view -b ${SAM_FLAGS} -o ${BAM_TMP}

# Sort the BAM file.
${BAM}: ${BAM+TMP}
	mkdir -p $(dir $@)
	samtools sort -@ ${CORES} ${BAM_TMP} -o ${BAM}

# Create the BAM index file.
${BAM}.bai: ${BAM}
	samtools index ${BAM}

# Generate the alignment.
align: ${BAM}.bai
	@ls -lh ${BAM}

# Run alignment.
run: align

# Remove BAM files.
run!:
	rm -f ${BAM_TMP} ${BAM} ${BAM}.bai

STATS = $(basename ${BAM}).stats

# Generate alignment stats.
${STATS}: ${BAM}.bai
	samtools flagstat ${BAM} > ${STATS}

# Trigger the statistics generation.
stats: ${STATS}
	@echo "# ${STATS}"
	@cat ${STATS}

# Install dependencies.
install::
	@echo micromamba install bwa samtools

# Targets that are not files.
.PHONY: usage index align run run! install
