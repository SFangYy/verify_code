
# Directories
RTL_DIR = ../rtl
ENV_DIR = ../env
SIM_DIR = ../sim

# Files
RTL_FILES = $(RTL_DIR)/alu.v $(RTL_DIR)/alu_if.sv
ENV_FILES = $(ENV_DIR)/alu_env.sv $(ENV_DIR)/alu_tb.sv $(ENV_DIR)/alu_test.sv

# Top-level testbench module
TB_TOP = alu_tb

# VCS Options
VCS_OPTS = -sverilog -debug_access+all -full64 -timescale=1ns/1ps +vcs+dumpvars+alu_tb.vcd

# Default target
default: run

# Compile and run
run: compile simulate

compile:
	vcs $(VCS_OPTS) $(RTL_FILES) $(ENV_FILES) -o $(TB_TOP).sim

simulate:
	./$(TB_TOP).sim

clean:
	rm -rf csrc *.sim *.vpd *.vcd ucli.key *.daidir

