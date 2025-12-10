# Procesador RISC-V Pipeline de 5 Etapas

Implementación de un procesador RISC-V de 32 bits con arquitectura pipeline de 5 etapas (IF/ID/EX/MEM/WB). El proyecto incluye detección y resolución de riesgos de datos (data hazards) mediante forwarding y stalling, así como resolución de riesgos de control (control hazards).

## Características

- **Arquitectura Pipeline**: 5 etapas (Fetch, Decode, Execute, Memory, Writeback)
- **Conjunto de Instrucciones**: Soporte para instrucciones R-type, I-type, S-type, B-type, U-type y J-type
- **Detección de Riesgos**:
  - RAW (Read-After-Write) hazards detectados y resueltos mediante forwarding
  - Load-Use hazards detectados con stalling
  - Control hazards resueltos mediante branch prediction y flushing
- **Memoria**:
  - Memoria de instrucciones de 64 palabras (256 bytes)
  - Memoria de datos de 4096 bytes (2^12 direcciones)
- **Operaciones Soportadas**:
  - Operaciones aritméticas: ADD, SUB, ADDI
  - Operaciones lógicas: AND, OR, XOR, ANDI, ORI, XORI
  - Operaciones de desplazamiento: SLL, SRL, SRA, SLLI, SRLI, SRAI
  - Comparaciones: SLT, SLTU, SLTI, SLTIU
  - Acceso a memoria: LW, LH, LB, SW, SH, SB (con soporte para carga/descarga con y sin signo)
  - Saltos: BEQ, BNE, BLT, BGE, BLTU, BGEU, JAL, JALR
  - Operaciones de inmediato: LUI, AUIPC

## Estructura del Proyecto

### `design/` - Módulos de Diseño

**Núcleo del Procesador:**
- `TOPPipeline.sv` - Módulo principal que integra todas las etapas del pipeline
- `PC.sv` - Contador de programa con manejo de saltos y stalls
- `RegisterFile.sv` - Banco de registros (32 registros de 32 bits)
- `InstructionMemory.sv` - Memoria de instrucciones ROM
- `DataMemory.sv` - Memoria de datos RAM

**Unidades de Control:**
- `Control.sv` - Generador de señales de control a partir del opcode
- `ALUcontrol.sv` - Decodificador de operaciones ALU basado en func3 y func7

**Unidades Aritméticas y Lógicas:**
- `RVALU.sv` - Unidad aritmético-lógica de 32 bits
- `adder.sv` - Sumador simple
- `Comparador.sv` - Comparador para igualdad de valores

**Generadores de Datos:**
- `ImmediateGenerator.sv` - Extensión de signo e inmediatos para distintos formatos de instrucción

**Registros de Pipeline:**
- `RegisterIF.sv` - Registro IF/ID
- `RegisterID.sv` - Registro ID/EX
- `RegisterEx.sv` - Registro EX/MEM
- `RegisterWb.sv` - Registro MEM/WB

**Multiplexores:**
- `Mux.sv` - Multiplexor 3-a-1 de 32 bits
- `DecoForwardMuxes.sv` - Lógica de selección para forwarding

**Detección de Riesgos:**
- `HazardUnit.sv` - Generador de señales de stall y flush
- `lwHazardUnit.sv` - Detector especializado de load-use hazards
- `RawHazardUnit.sv` - Detector de RAW hazards y generador de señales de forwarding
- `IDRawHazard.sv` - Detector de hazards en la etapa ID
- `branchstall.sv` - Manejo de stalls relacionados con saltos

### `sim/` - Testbenches

Testbenches unitarios para validación de módulos individuales:
- `ALUControl_tb.sv` - Pruebas del decodificador ALU
- `Control_tb.sv` - Pruebas de la unidad de control
- `RVALU_tb.sv` - Pruebas de la ALU (operaciones aritméticas, lógicas, comparaciones)
- `RegisterFile_tb.sv` - Pruebas del banco de registros
- `DataMemory_tb.sv` - Pruebas de la memoria de datos
- `ImmediateGenerator_tb.sv` - Pruebas del generador de inmediatos
- `lwHazardUnit_tb.sv` - Pruebas del detector de load-use hazards
- `RawHazardUnit_tb.sv` - Pruebas del detector de RAW hazards
- `Comparador_tb.sv` - Pruebas del comparador
- `TOPPipeline_tb.sv` - Prueba de integración del procesador completo

### `build/` - Sistema de Compilación

- `Makefile` - Script de compilación y ejecución de simulaciones
  - `make test` - Compila y ejecuta el testbench (por defecto TOPPipeline_tb)
  - `make wv` - Abre gtkwave con el archivo VCD generado
  - `make clean` - Limpia archivos generados

## Requisitos

- **Simulador**: Icarus Verilog (iverilog) con soporte para SystemVerilog 2005
- **Herramientas**:
  - `make` - Para ejecutar el build
  - `gtkwave` - Para visualizar formas de onda (opcional)
- **Sistema Operativo**: Linux, macOS o Windows (con WSL/Git Bash)

## Instalación

### Linux/macOS
```bash
# Instalar iverilog y gtkwave
brew install iverilog gtkwave  # macOS
sudo apt install iverilog gtkwave  # Ubuntu/Debian
```

### Windows (WSL/Git Bash)
```bash
# En WSL
sudo apt install iverilog gtkwave make

# O en Git Bash (si está disponible)
pacman -S iverilog gtkwave make
```

## Uso

### Compilar y Ejecutar Simulaciones

```bash
cd build
make          # Compila y ejecuta el testbench por defecto (TOPPipeline_tb)
make test     # Compila y ejecuta el testbench
make wv       # Abre gtkwave con la forma de onda generada
make clean    # Limpia archivos generados
```

### Cambiar el Testbench a Ejecutar

Editar el archivo `build/Makefile` y cambiar la variable `test_name`:

```makefile
# Cambiar de:
test_name = TOPPipeline_tb
# A:
test_name = RVALU_tb
# O cualquier otro testbench disponible en sim/
```

### Ejemplo de Ejecución

```bash
cd build

# Ejecutar pruebas de la ALU
make test_name=RVALU_tb test

# Ejecutar pruebas del banco de registros
make test_name=RegisterFile_tb test

# Ejecutar pruebas de la memoria
make test_name=DataMemory_tb test

# Ejecutar pruebas del generador de inmediatos
make test_name=ImmediateGenerator_tb test

# Ejecutar pruebas del procesador completo
make test_name=TOPPipeline_tb test
```

## Flujo de la Simulación

1. **IF (Instruction Fetch)**: Lee instrucción de memoria, incrementa PC
2. **ID (Instruction Decode)**: Decodifica instrucción, lee registros, extiende inmediato
3. **EX (Execute)**: Ejecuta operación ALU, calcula direcciones de salto
4. **MEM (Memory)**: Lee o escribe en memoria de datos
5. **WB (Write Back)**: Escribe resultado en banco de registros

### Manejo de Riesgos

- **RAW Hazards**: Detectados por `RawHazardUnit.sv` y resueltos mediante forwarding desde etapas MEM y WB
- **Load-Use Hazards**: Detectados por `lwHazardUnit.sv`, requieren un ciclo de stall
- **Control Hazards**: Saltos se resuelven en EX, se hace flush de instrucciones en IF/ID si es necesario

## Archivos de Salida

Después de ejecutar una simulación, se generan:
- `sim_output.o` - Archivo compilado de Verilog
- `{test_name}.vcd` - Archivo de forma de onda (Visual Change Dump) visualizable en gtkwave

## Notas de Implementación

- **Ancho de datos**: 32 bits
- **Profundidad de memoria de instrucciones**: 64 palabras (256 bytes)
- **Profundidad de memoria de datos**: 4096 bytes (direccionamiento por byte)
- **Registros**: 32 registros de 32 bits (x0-x31)
- **Período de reloj**: 10 ns (por defecto en testbenches)
- **Compatible**: Icarus Verilog con flag `-g2005-sv`

## Limitaciones Conocidas

- No hay soporte para interrupciones o excepciones
- No hay caché (usa memoria de una sola etapa)
- Las direcciones de memoria requieren alineación manual
- No implementa instrucciones de punto flotante (RV-F, RV-D)
