#
# Downloads sequencing reads from SRA.
#

# Directory for storing FASTQ reads.
DIR ?= reads

# SRR number
SRR ?=

# The name of pair-end reads.
R1 ?= ${DIR}/${SRR}_1.fastq
R2 ?= ${DIR}/${SRR}_2.fastq

# Number of reads to download (N=all downloads all reads).
N ?= 10000

# Makefile customizations.
.DELETE_ON_ERROR:
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables --no-print-directory

# Print usage information.
usage::
	@echo ""
	@echo "SRA module - download FASTQ reads from SRA"
	@echo ""
	@echo "Usage:   make -f ~/workflows/run/sra.mk <SRR> [N]"
	@echo ""
	@echo "Command: SRR 	read accession"
	@echo "         N   	number of reads to download (use ALL to download all reads)"
	@echo ""

# Set the flags for the download.
ifeq (${N}, ALL)
FLAGS = -F --split-files
else
FLAGS = -F --split-files -X ${N}
endif

${R1}:
	mkdir -p ${DIR}
	fasterq-dump ${FLAGS} -O ${DIR} ${SRR}

# List the data.
run: ${R1}
	@if [ -f ${R2} ]; then
		@ls -lh ${R1} ${R2}
	else
		@ls -lh ${R1}
	fi

# Remove SRA files.
run!:
	rm -f ${R1} ${R2}

install::
	@echo micromamba install sra-tools

# Targets that are not files.
.PHONY: usage run run! install
