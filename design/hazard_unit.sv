// ==============================================================================
// HAZARD DETECTION UNIT
// ==============================================================================

module hazard_unit(
  // Inputs from ID stage
  input logic [4:0] id_rs1,
  input logic [4:0] id_rs2,
  input logic id_memread,
  // Inputs from EX stage
  input logic [4:0] ex_rd,
  input logic ex_memread,
  // Outputs
  output logic stall,
  output logic if_flush
);

  // Load-use hazard detection
  // Stall if: EX stage has memory read AND destination register matches RS1 or RS2
  // AND destination register is not x0 (zero register)
  always_comb begin
    stall = 1'b0;
    if_flush = 1'b0;
    
    if (ex_memread && ((ex_rd == id_rs1) || (ex_rd == id_rs2)) && (ex_rd != 5'b00000)) begin
      stall = 1'b1;      // Stall pipeline
      if_flush = 1'b1;   // Insert bubble (NOP)
    end
  end

endmodule

// =============================================================================="
