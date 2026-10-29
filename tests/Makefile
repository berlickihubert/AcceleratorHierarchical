ROOT       := $(abspath ../../..)
PYTHON_BIN ?= $(ROOT)/.venv/bin/python
VENV_DIR   := $(abspath $(dir $(PYTHON_BIN))/..)
SIM        ?= verilator

SV_DIR := $(abspath ..)/src

PE_SV  := $(SV_DIR)/PE.sv

.PHONY: help test accelerator_top clean

help:
	@echo "cele: test accelerator_top clean"

test: accelerator_top

accelerator_top:
	bash -c '\
		unset TEST SIM_BUILD VERILOG_SOURCES TOPLEVEL MODULE PARAMS EXTRA_ARGS COMPILE_ARGS; \
		source $(VENV_DIR)/bin/activate && \
		$(MAKE) -f $(ROOT)/Makefile.test \
			SIM=$(SIM) \
			PROJECT_DIR=$(abspath ..) \
			TOPLEVEL=AcceleratorTop \
			MODULE=tests.AcceleratorTopTest \
			SIM_BUILD=sim_build_accelerator_top \
			VERILOG_SOURCES="$(PE_SV) $(SV_DIR)/SystolicTableHierarchical.sv $(SV_DIR)/AcceleratorTop.sv"'

clean:
	rm -rf sim_build_* results.xml dump.vcd __pycache__
