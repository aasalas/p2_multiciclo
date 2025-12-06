// ==============================================================================
// PIPELINE REGISTER MODULES
// ==============================================================================

// IF/ID Pipeline Register
module if_id_reg(
  input logic clk,
  input logic flush,
  input logic stall,
  input logic [31:0] pc_in,
  input logic [31:0] instr_in,
  output logic [31:0] pc_out,
  output logic [31:0] instr_out
);
  logic [31:0] pc_r, instr_r;
  
  always_ff @(posedge clk) begin
    if (flush) begin
      pc_r <= 32'd0;
      instr_r <= 32'd0;
    end else if (!stall) begin
      pc_r <= pc_in;
      instr_r <= instr_in;
    end
  end
  
  assign pc_out = pc_r;
  assign instr_out = instr_r;
endmodule

// ==============================================================================

// ID/EX Pipeline Register
module id_ex_reg(
  input logic clk,
  input logic flush,
  input logic [31:0] pc_in,
  input logic [31:0] rd1_in,
  input logic [31:0] rd2_in,
  input logic [31:0] imm_in,
  input logic [4:0] rs1_in,
  input logic [4:0] rs2_in,
  input logic [4:0] rd_in,
  input logic regwrite_in,
  input logic memtoreg_in,
  input logic memread_in,
  input logic memwrite_in,
  input logic branch_in,
  input logic [1:0] aluop_in,
  input logic alusrc_in,
  output logic [31:0] pc_out,
  output logic [31:0] rd1_out,
  output logic [31:0] rd2_out,
  output logic [31:0] imm_out,
  output logic [4:0] rs1_out,
  output logic [4:0] rs2_out,
  output logic [4:0] rd_out,
  output logic regwrite_out,
  output logic memtoreg_out,
  output logic memread_out,
  output logic memwrite_out,
  output logic branch_out,
  output logic [1:0] aluop_out,
  output logic alusrc_out
);
  always_ff @(posedge clk) begin
    if (flush) begin
      pc_out <= '0;
      rd1_out <= '0;
      rd2_out <= '0;
      imm_out <= '0;
      rs1_out <= '0;
      rs2_out <= '0;
      rd_out <= '0;
      regwrite_out <= '0;
      memtoreg_out <= '0;
      memread_out <= '0;
      memwrite_out <= '0;
      branch_out <= '0;
      aluop_out <= '0;
      alusrc_out <= '0;
    end else begin
      pc_out <= pc_in;
      rd1_out <= rd1_in;
      rd2_out <= rd2_in;
      imm_out <= imm_in;
      rs1_out <= rs1_in;
      rs2_out <= rs2_in;
      rd_out <= rd_in;
      regwrite_out <= regwrite_in;
      memtoreg_out <= memtoreg_in;
      memread_out <= memread_in;
      memwrite_out <= memwrite_in;
      branch_out <= branch_in;
      aluop_out <= aluop_in;
      alusrc_out <= alusrc_in;
    end
  end
endmodule

// ==============================================================================

// EX/MEM Pipeline Register
module ex_mem_reg(
  input logic clk,
  input logic [31:0] alu_res_in,
  input logic [31:0] rd2_in,
  input logic [4:0] rd_in,
  input logic regwrite_in,
  input logic memtoreg_in,
  input logic memread_in,
  input logic memwrite_in,
  output logic [31:0] alu_res_out,
  output logic [31:0] rd2_out,
  output logic [4:0] rd_out,
  output logic regwrite_out,
  output logic memtoreg_out,
  output logic memread_out,
  output logic memwrite_out
);
  always_ff @(posedge clk) begin
    alu_res_out <= alu_res_in;
    rd2_out <= rd2_in;
    rd_out <= rd_in;
    regwrite_out <= regwrite_in;
    memtoreg_out <= memtoreg_in;
    memread_out <= memread_in;
    memwrite_out <= memwrite_in;
  end
endmodule

// ==============================================================================

// MEM/WB Pipeline Register
module mem_wb_reg(
  input logic clk,
  input logic [31:0] mem_data_in,
  input logic [31:0] alu_res_in,
  input logic [4:0] rd_in,
  input logic regwrite_in,
  input logic memtoreg_in,
  output logic [31:0] mem_data_out,
  output logic [31:0] alu_res_out,
  output logic [4:0] rd_out,
  output logic regwrite_out,
  output logic memtoreg_out
);
  always_ff @(posedge clk) begin
    mem_data_out <= mem_data_in;
    alu_res_out <= alu_res_in;
    rd_out <= rd_in;
    regwrite_out <= regwrite_in;
    memtoreg_out <= memtoreg_in;
  end
endmodule

// =============================================================================="
