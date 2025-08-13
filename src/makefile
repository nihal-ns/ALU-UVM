# Makefile for SystemVerilog Simulation

# --- Variables ---
FILE ?= top.sv
TOP ?= top

# --- Simulation Options ---
# This section sets the simulation flags based on the VERBOSITY variable.
VERBOSITY ?= NORMAL
VSIM_EXTRA_OPTS =

ifeq ($(VERBOSITY), HIGH)
	VSIM_EXTRA_OPTS = +UVM_VERBOSITY=UVM_HIGH
endif
ifeq ($(VERBOSITY), DEBUG)
	VSIM_EXTRA_OPTS = +UVM_VERBOSITY=UVM_DEBUG
endif


# --- Targets ---
.PHONY: all compile simulate clean h d

# Default target runs a normal simulation
all: simulate

# --- Shortcut Targets ---
# These targets call 'simulate' silently using the --no-print-directory flag.
h:
	@$(MAKE) --no-print-directory simulate VERBOSITY=HIGH

d:
	@$(MAKE) --no-print-directory simulate VERBOSITY=DEBUG
# --- End of Shortcut Targets ---


compile:
	@vlog -sv $(FILE)

simulate: compile
	@echo "--- Running Simulation (Verbosity: $(VERBOSITY)) ---"
	@vsim -c $(TOP) $(VSIM_EXTRA_OPTS) -do "run -all ; quit"

clean:
	@rm -rf transcript vsim.wlf work *.log
