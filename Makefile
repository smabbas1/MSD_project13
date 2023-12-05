# Makefile for Questa Sim simulator

# Compiler and simulator settings
VLOG = vlog
VSIM = vsim
VLOG_FLAGS = -sv +define+DEBUG_ON
VSIM_FLAGS = -c -voptargs=+acc

# Source files
SRC_FILES = scheduler.sv

# Default input and output file names
INPUT_FILE = trace1.txt
OUTPUT_FILE = dram1.txt

# Makefile targets
all: compile simulate

compile:
	$(VLOG) $(VLOG_FLAGS) $(SRC_FILES)

simulate:
	$(VSIM) $(VSIM_FLAGS) +input=$(INPUT_FILE) +output=$(OUTPUT_FILE) scheduler -do "run -all"

clean:
	rm -rf work transcript *.log vsim.wlf $(OUTPUT_FILE)

.PHONY: all compile simulate clean





