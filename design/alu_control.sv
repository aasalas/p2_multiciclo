

module alu_control(
  input logic [1:0] aluop, 
  input logic [2:0] funct3,
  input logic funct7_5,
  output logic [3:0] alu_ctrl
  );
  
  always_comb begin
    alu_ctrl = 4'd0;
    if (aluop==2'b00) alu_ctrl = 4'd0; // add (for load/store)
    else if (aluop==2'b01) alu_ctrl = 4'd1; // sub (for branch cmp)
    else if (aluop==2'b10) begin // R-type
      case({funct7_5,funct3})
        4'b0000: alu_ctrl = 4'd0; // ADD
        4'b1000: alu_ctrl = 4'd1; // SUB
        4'b0001: alu_ctrl = 4'd2; // SLL -> map to AND (simplified)
        default: alu_ctrl = 4'd0;
      endcase
    end else if (aluop==2'b11) begin // I-type ALU
      case(funct3)
        3'b000: alu_ctrl = 4'd0; // ADDI
        default: alu_ctrl = 4'd0;
      endcase
    end
  end
endmodule