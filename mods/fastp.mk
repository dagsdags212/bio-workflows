# 
# Trims FASTQ reads and runs QC on them.
#

# SRR numbers may also be used as input.
SRR ?=

# The input read pairs.
R1 ?= reads/${SRR}_1.fastq
R2 ?=

# Set MODE to to either SE or PE
ifeq (${R2},)
	MODE = SE
	Q1 ?= trim/$(notdir ${R1})
	Q2 ?=
else
	MODE = PE
	Q1 ?= trim/$(notdir ${R1})
	Q2 ?= trim/$(notdir ${R2})
endif

# Number of CPU cores to use.
CORES ?= 4

# The adapter sequence for trimming.
ADAPTER ?= AGATTCGGAAGAGCACACGTCTGAACTCCAGTCAC

# The statistics on the read files.
READ_STATS ?= $(basename ${Q1}).stats

# fastp HTML report
FASTP_HTML = $(basename ${Q1}).html

# Makefile customizations.
SHELL := bash
.DELETE_ON_ERROR:
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables --no-print-directory

# Print usage information.
usage:
	@echo ""
	@echo "fastp module - FASTQ quality control with fastp"
	@echo ""
	@echo "Usage:   make -f ~/workflows/run/fastp.mk run <R1> [R2]"
	@echo ""

FASTP_FLAGS ?= --adapter_sequence ${ADAPTER} --cut_right --cut_right_mean_quality 30 --length_required 50 -j /dev/null -h ${FASTP_HTML}

ifeq ($(MODE), PE)
CMD = fastp -i ${R1} -I ${R2} -o ${Q1} -O ${Q2} -w ${CORES} ${FASTP_FLAGS}
else
CMD = fastp -i ${R1} -o ${Q1} -w ${CORES} ${FASTP_FLAGS}
endif

# Perform the trimming.
${Q1} ${Q2}: ${R1} ${R2}
	mkdir -p $(dir ${Q1})
	${CMD}

run: ${Q1} ${Q2}
	@ls -lh ${Q1} ${Q2}

# Remove trimmed files.
run!:
	rm -f ${Q1} ${Q2}

# Install instructions.
install:
	@echo micromamba install fastp

# Targets that are not files.
.PHONY: run install usage
