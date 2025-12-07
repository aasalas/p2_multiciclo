// ==============================================================================
// FILE INCLUDES
// ==============================================================================

module TOP_IF(
  input logic clk,
  input logic rst
);

  // ============================================================================
  // STAGE 1: INSTRUCTION FETCH (IF)
  // PC comienza en 0 y se le suma 4 en cada ciclo de reloj
  // En cada ciclo se lee la instrucción de la memoria de instrucciones
  // ============================================================================
  
  logic [31:0] pc;
  logic [31:0] instr_if;
  
  // Instanciar el módulo de program counter
  pc pc_unit(
    .clk(clk),
    .pc_out(pc)
  );
  
  instr_mem imem(
    .clk(clk),
    .pc(pc),
    .instr(instr_if)
  );

endmodule