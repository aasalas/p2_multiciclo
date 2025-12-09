# Makefile para simulación con iverilog y gtkwave

# Directorios
DESIGN_DIR = ../design
SIM_DIR = ../sim

# Fuentes de diseño - orden importante: primero los módulos base, luego los que los usan
SOURCES = $(wildcard ../design/*.v ../design/*.sv)
		
# CAMBIAR SOLO EL NOMBRE DEL TESTBENCH
test_name = lwHazardUnit_tb
TESTBENCH = $(SIM_DIR)/$(test_name).sv # Fuente de simulación (testbench)
TOP_TB = $(test_name) # Módulo top del testbench
VCD_FILE = $(test_name).vcd # Archivo VCD para visualización

# Archivo de salida
OUTPUT = sim_output.o


.PHONY: all test wv clean

all: test wv

test:
	iverilog -g2005-sv -I../design -s $(TOP_TB) -o $(OUTPUT) $(SOURCES) $(TESTBENCH)
	vvp $(OUTPUT)

wv: $(VCD_FILE)
	gtkwave $(VCD_FILE)

clean:
	rm -f $(OUTPUT) $(VCD_FILE)
