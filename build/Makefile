# Makefile para simulación con iverilog y gtkwave

# Directorios
DESIGN_DIR = ../design
SIM_DIR = ../sim

# Fuentes de diseño - solo los módulos independientes que no están incluidos
SOURCES = $(DESIGN_DIR)/mux_2_1.sv \
          $(DESIGN_DIR)/mux_3_1.sv
SOURCES = $(wildcard ../design/*.v ../design/*.sv)
# Fuente de simulación (testbench)
TESTBENCH = $(SIM_DIR)/mux_2_1_tb.sv

# Módulo top del testbench
TOP_TB = mux_2_1_tb

# Archivo de salida
OUTPUT = sim_output.vcd

# Archivo VCD para visualización
VCD_FILE = mux_2_1_tb.vcd

.PHONY: all test wv clean

all: test wv

test:
	iverilog -g2005-sv -I../design -s $(TOP_TB) -o $(OUTPUT) $(SOURCES) $(TESTBENCH)
	vvp $(OUTPUT)

wv: $(VCD_FILE)
	gtkwave $(VCD_FILE)

clean:
	rm -f $(OUTPUT) $(VCD_FILE)
