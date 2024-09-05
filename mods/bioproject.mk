#
# Downloads NCBI run information from a given bioproject number.
#

# Project number.
ID ?=

# Project runinfo file.
OUT ?= ${ID}.csv

# Makefile customizations.
.DELETE_ON_ERROR:
.ONESHELL:
MAKEFLAGS += --warn-undefined-variables --no-print-directory

# General usage information.
usage::
	@echo ""
	@echo "Bioproject module - download runinfo from an SRA bioproject"
	@echo ""
	@echo "Usage: make -f ~/workflows/run/bioproject.mk get <ID>"
	@echo ""

${OUT}:
	mkdir -p $(dir $@)
	bio search ${ID} --header --csv > $@

# Target to download all the data.
get:: ${OUT}
	@ls -lh ${OUT}

get!::
	rm -rf ${OUT}

install:
	@echo "pip install bio --upgrade"
