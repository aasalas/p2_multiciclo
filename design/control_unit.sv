// ==============================================================================
// CONTROL UNIT
// ==============================================================================
// Decodes RISC-V opcodes and generates control signals for the pipeline

module control_unit(
  input logic [6:0] opcode,
  output logic regwrite,
  output logic memtoreg,
  output logic memread,
  output logic memwrite,
  output logic branch,
  output logic [1:0] aluop,
  output logic alusrc
);

  // Combinational logic for control signal generation
  always_comb begin
    // Default values
    regwrite = 1'b0;
    memtoreg = 1'b0;
    memread = 1'b0;
    memwrite = 1'b0;
    branch = 1'b0;
    aluop = 2'b00;
    alusrc = 1'b0;

    // Decode opcode and set appropriate control signals
    case(opcode)
      
      // R-type: ADD, SUB, AND, OR, XOR, etc.
      7'b0110011: begin
        regwrite = 1'b1;
        aluop = 2'b10;
        alusrc = 1'b0;
        memtoreg = 1'b0;
      end

      // I-type ALU: ADDI, ANDI, ORI, etc.
      7'b0010011: begin
        regwrite = 1'b1;
        aluop = 2'b11;
        alusrc = 1'b1;
      end

      // Load: LW, LH, LB, etc.
      7'b0000011: begin
        regwrite = 1'b1;
        memtoreg = 1'b1;
        memread = 1'b1;
        alusrc = 1'b1;
        aluop = 2'b00;
      end

      // Store: SW, SH, SB, etc.
      7'b0100011: begin
        memwrite = 1'b1;
        alusrc = 1'b1;
        aluop = 2'b00;
      end

      // Branch: BEQ, BNE, BLT, BGE, etc.
      7'b1100011: begin
        branch = 1'b1;
        aluop = 2'b01;
        alusrc = 1'b0;
      end

      // Default case: all signals remain 0
      default: begin
      end

    endcase
  end

endmodule

// =============================================================================="
