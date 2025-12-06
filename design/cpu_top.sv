// ==============================================================================
// FILE INCLUDES
// ==============================================================================
`include "instr_mem.sv"
`include "data_mem.sv"
`include "regfile.sv"
`include "alu.sv"
`include "imm_gen.sv"
`include "control_unit.sv"
`include "alu_control.sv"
`include "pipeline_regs.sv"
`include "hazard_unit.sv"
`include "forwarding_unit.sv"

// ==============================================================================
// CPU TOP MODULE - 5-STAGE PIPELINE RISC-V PROCESSOR
// ==============================================================================

module cpu_top(
  input logic clk,
  input logic rst
);

  // ============================================================================
  // STAGE 1: INSTRUCTION FETCH (IF)
  // ============================================================================
  logic [31:0] pc;
  logic [31:0] pc_next;
  logic [31:0] instr_if;
  
  instr_mem imem(
    .clk(clk),
    .addr(pc),
    .instr(instr_if)
  );

  // ============================================================================
  // PIPELINE: IF/ID REGISTER
  // ============================================================================
  logic [31:0] pc_id;
  logic [31:0] instr_id;
  
  if_id_reg ifid(
    .clk(clk),
    .flush(1'b0),
    .stall(1'b0),
    .pc_in(pc),
    .instr_in(instr_if),
    .pc_out(pc_id),
    .instr_out(instr_id)
  );

  // ============================================================================
  // STAGE 2: INSTRUCTION DECODE (ID)
  // ============================================================================
  
  // Extract opcode and register addresses
  logic [6:0] opcode_id;
  logic [4:0] rs1_id, rs2_id, rd_id;
  
  assign opcode_id = instr_id[6:0];
  assign rs1_id = instr_id[19:15];
  assign rs2_id = instr_id[24:20];
  assign rd_id = instr_id[11:7];

  // Immediate generation
  logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
  
  imm_gen immgen(
    .instr(instr_id),
    .imm_i(imm_i),
    .imm_s(imm_s),
    .imm_b(imm_b),
    .imm_u(imm_u),
    .imm_j(imm_j)
  );

  // Control signals
  logic regwrite_id, memtoreg_id, memread_id, memwrite_id, branch_id, alusrc_id;
  logic [1:0] aluop_id;
  
  control_unit ctrl(
    .opcode(opcode_id),
    .regwrite(regwrite_id),
    .memtoreg(memtoreg_id),
    .memread(memread_id),
    .memwrite(memwrite_id),
    .branch(branch_id),
    .aluop(aluop_id),
    .alusrc(alusrc_id)
  );

  // Register file read
  logic [31:0] rd1_id, rd2_id;
  
  regfile regs(
    .clk(clk),
    .we(1'b1),
    .ra1(rs1_id),
    .ra2(rs2_id),
    .wa(5'd0),
    .wd(32'd0),
    .rd1(rd1_id),
    .rd2(rd2_id)
  );

  // ============================================================================
  // PIPELINE: ID/EX REGISTER
  // ============================================================================
  logic [31:0] pc_ex, rd1_ex, rd2_ex, imm_ex;
  logic [4:0] rs1_ex, rs2_ex, rd_ex;
  logic regwrite_ex, memtoreg_ex, memread_ex, memwrite_ex, branch_ex, alusrc_ex;
  logic [1:0] aluop_ex;
  
  id_ex_reg idex(
    .clk(clk),
    .flush(1'b0),
    .pc_in(pc_id),
    .rd1_in(rd1_id),
    .rd2_in(rd2_id),
    .imm_in(imm_i),
    .rs1_in(rs1_id),
    .rs2_in(rs2_id),
    .rd_in(rd_id),
    .regwrite_in(regwrite_id),
    .memtoreg_in(memtoreg_id),
    .memread_in(memread_id),
    .memwrite_in(memwrite_id),
    .branch_in(branch_id),
    .aluop_in(aluop_id),
    .alusrc_in(alusrc_id),
    .pc_out(pc_ex),
    .rd1_out(rd1_ex),
    .rd2_out(rd2_ex),
    .imm_out(imm_ex),
    .rs1_out(rs1_ex),
    .rs2_out(rs2_ex),
    .rd_out(rd_ex),
    .regwrite_out(regwrite_ex),
    .memtoreg_out(memtoreg_ex),
    .memread_out(memread_ex),
    .memwrite_out(memwrite_ex),
    .branch_out(branch_ex),
    .aluop_out(aluop_ex),
    .alusrc_out(alusrc_ex)
  );

  // ============================================================================
  // STAGE 3: EXECUTE (EX)
  // ============================================================================
  
  // ALU inputs and outputs
  logic [31:0] alu_in1, alu_in2, alu_res_ex;
  logic zero_ex;
  logic [3:0] alu_ctrl;
  
  // ALU control generation
  logic [2:0] funct3_ex;
  logic funct7_5_ex;
  
  assign funct3_ex = pc_ex[14:12];     // Placeholder: in real design take from instr
  assign funct7_5_ex = 1'b0;
  
  alu_control aluctrl(
    .aluop(aluop_ex),
    .funct3(funct3_ex),
    .funct7_5(funct7_5_ex),
    .alu_ctrl(alu_ctrl)
  );

  // Forwarding logic (hooks for expansion)
  // TODO: Connect signals from EX/MEM and MEM/WB stages through forwarding unit
  assign alu_in1 = rd1_ex;
  assign alu_in2 = (alusrc_ex) ? imm_ex : rd2_ex;
  
  alu alu0(
    .a(alu_in1),
    .b(alu_in2),
    .alu_ctrl(alu_ctrl),
    .result(alu_res_ex),
    .zero(zero_ex)
  );

  // ============================================================================
  // PIPELINE: EX/MEM REGISTER
  // ============================================================================
  logic [31:0] alu_res_mem, rd2_mem;
  logic [4:0] rd_mem;
  logic regwrite_mem, memtoreg_mem, memread_mem, memwrite_mem;
  
  ex_mem_reg exmem(
    .clk(clk),
    .alu_res_in(alu_res_ex),
    .rd2_in(rd2_ex),
    .rd_in(rd_ex),
    .regwrite_in(regwrite_ex),
    .memtoreg_in(memtoreg_ex),
    .memread_in(memread_ex),
    .memwrite_in(memwrite_ex),
    .alu_res_out(alu_res_mem),
    .rd2_out(rd2_mem),
    .rd_out(rd_mem),
    .regwrite_out(regwrite_mem),
    .memtoreg_out(memtoreg_mem),
    .memread_out(memread_mem),
    .memwrite_out(memwrite_mem)
  );

  // ============================================================================
  // STAGE 4: MEMORY ACCESS (MEM)
  // ============================================================================
  logic [31:0] mem_rdata;
  
  data_mem dmem(
    .clk(clk),
    .memread(memread_mem),
    .memwrite(memwrite_mem),
    .addr(alu_res_mem),
    .wdata(rd2_mem),
    .rdata(mem_rdata)
  );

  // ============================================================================
  // PIPELINE: MEM/WB REGISTER
  // ============================================================================
  logic [31:0] mem_rdata_wb, alu_res_wb;
  logic [4:0] rd_wb;
  logic regwrite_wb, memtoreg_wb;
  
  mem_wb_reg memwb(
    .clk(clk),
    .mem_data_in(mem_rdata),
    .alu_res_in(alu_res_mem),
    .rd_in(rd_mem),
    .regwrite_in(regwrite_mem),
    .memtoreg_in(memtoreg_mem),
    .mem_data_out(mem_rdata_wb),
    .alu_res_out(alu_res_wb),
    .rd_out(rd_wb),
    .regwrite_out(regwrite_wb),
    .memtoreg_out(memtoreg_wb)
  );

  // ============================================================================
  // STAGE 5: WRITE BACK (WB)
  // ============================================================================
  // TODO: Implement register file write-back logic
  // Write selected data (memory or ALU result) to register file

endmodule

// =============================================================================="