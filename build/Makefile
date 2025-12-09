# Makefile para simulación con iverilog y gtkwave

# Directorios
DESIGN_DIR = ../design
SIM_DIR = ../sim

# Fuentes de diseño - orden importante: primero los módulos base, luego los que los usan
SOURCES = $(wildcard ../design/*.v ../design/*.sv)
		
#SOURCES = $(wildcard ../design/*.v ../design/*.sv)
# Fuente de simulación (testbench)
TESTBENCH = $(SIM_DIR)/TOPPipeline_tb.sv

# Módulo top del testbench
TOP_TB = TOPPipeline_tb

# Archivo de salida
OUTPUT = sim_output.o

# Archivo VCD para visualización
VCD_FILE = TOPPipeline_tb.vcd

.PHONY: all test wv clean

all: test wv

test:
	iverilog -g2005-sv -I../design -s $(TOP_TB) -o $(OUTPUT) $(SOURCES) $(TESTBENCH)
	vvp $(OUTPUT)

wv: $(VCD_FILE)
	gtkwave $(VCD_FILE)

clean:
	rm -f $(OUTPUT) $(VCD_FILE)
