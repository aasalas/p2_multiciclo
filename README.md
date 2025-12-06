# Procesador RISC-V Multiciclo

Proyecto de implementación de un procesador RISC-V con arquitectura pipeline.

## Estructura del Proyecto

- `design/` - Archivos fuente en SystemVerilog
  - `cpu_top.sv` - Top module del procesador
  - `control_unit.sv` - Unidad de control
  - `alu.sv` - Unidad aritmético-lógica
  - `regfile.sv` - Banco de registros
  - `pipeline_regs.sv` - Registros de pipeline
  - `hazard_unit.sv` - Unidad de detección de riesgos
  - `forwarding_unit.sv` - Unidad de adelantamiento
  - Y otros módulos...
- `build/` - Scripts de compilación
- `sim/` - Directorio para simulaciones

## Requisitos

- Simulador compatible con SystemVerilog (ModelSim, Verilator, Icarus Verilog)
- Make

## Uso

```bash
cd build
make
```
