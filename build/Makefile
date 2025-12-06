#Makefile con todo el flujo de trabajo para GOWIN. Utilizando iverilog y gtkwave


#Nombre del proyecto... 
PROYECT = Multiciclo 

#Fuentes de diseno
SOURCES := $(wildcard ../design/*.v ../design/*.sv) #Todas las fuentes .v o .sv que estan en design


#Fuente de simulacion
#aca va el testbench que quieran simular
TESTBENCH = ../sim/


#el top se indica sin la extension .v, esto hace referencia al nombre que le pusieron al módulo y no al archivo en si.
TOP_DESIGN =
TOP_TB     = 

#nombre del vcd que va a generar el tb
VCD_FILE =


all: test wv # testea y muestra la simulacion en gtkwave

#Generar vcd con icarus verilog
test: ${SOURCES} ${TESTBENCH}
	@iverilog -o ${PROYECT}_test.o -s ${TOP_TB} -g2005-sv ${TESTBENCH} ${SOURCES}
	@vvp ${PROYECT}_test.o 
	
#Visualizar los diagramas de tiempo con GTKWave
wv: ${VCD_FILE}
	gtkwave ${VCD_FILE} 
        

.PHONY:  wv
