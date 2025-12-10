module TOPPipeline #(parameter WIDTH=32, parameter DEPTH_IMEM=64, parameter DEPTH_DMEM=12, parameter WIDTH2=5) (
    input logic clk, rst
);

    //Data Hazard
    logic FlushE,StallD,StallF,lwstall,branchstall, IDhazardStall;
    logic [1:0] ForwardAE;
    logic [1:0] ForwardBE;
    logic [WIDTH-1:0]ForwardDataBE;

    //Control Hazard
    logic [WIDTH-1:0] Mux_RD1;
    logic [WIDTH-1:0] Mux_RD2;
    logic EqualD;
    logic ForwardAD,ForwardBD;
    logic wrm_eq_rsD;
    logic wrm_eq_rtD;
    logic wre_eq_rsD;
    logic wre_eq_rtD;


    // Etapa IF
    logic [WIDTH-1:0] PC_current, PC_next;
    logic [WIDTH-1:0] PC_plus4;
    logic [WIDTH-1:0] instruction_IF;
    
    // Pipeline IF/ID
    logic [WIDTH-1:0] instruction_ID, PC_ID;
    
    // Etapa ID
    logic [6:0] opcode;
    logic [2:0] func3;
    logic [6:0] func7;
    logic [4:0] Rs1, Rs2, Rd_ID;
    logic [WIDTH-1:0] ReadData1, ReadData2;
    logic [WIDTH-1:0] ImmExt_ID;
    logic [3:0] ALUCtrl_ID;
    
    // Señales de control ID
    logic RegWrite_ID, ALUSrc_ID, MemRead_ID, MemWrite_ID, MemtoReg_ID;
    logic Branch_ID, Jump_ID;
    logic [1:0] ALUOp_ID;
    logic one_byte_ID, two_byte_ID, four_bytes_ID, unsigned_load_ID;
    
    // Pipeline ID/EX
    logic [WIDTH-1:0] PC_EX, ReadData1_EX, ReadData2_EX, ImmExt_EX;
    logic [4:0] Rd_EX, Rs1_EX,Rs2_EX;
    logic [3:0] ALUCtrl_EX;
    logic RegWrite_EX, ALUSrc_EX, MemRead_EX, MemWrite_EX, MemtoReg_EX;
    logic Branch_EX, Jump_EX;
    logic [1:0] ALUOp_EX;
    logic one_byte_EX, two_byte_EX, four_bytes_EX, unsigned_load_EX;
    
    // Etapa EX
    logic [WIDTH-1:0] ALU_a, ALU_b, ALUResult_EX;
    logic [WIDTH-1:0] PC_branch_target, PC_jump_target;
    logic Zero_EX, Comparison_EX;
    logic PCSrc_Branch, PCSrc_Jump, PCSrc;
    
    // Pipeline EX/MEM
    logic [WIDTH-1:0] PC_branch_MEM, ALUResult_MEM, WriteData_MEM;
    logic [4:0] Rd_MEM;
    logic Branch_MEM, Jump_MEM, MemRead_MEM, MemWrite_MEM;
    logic RegWrite_MEM, MemtoReg_MEM;
    logic one_byte_MEM, two_byte_MEM, four_bytes_MEM, unsigned_load_MEM;
    logic Comparison_MEM;
    
    // Etapa MEM
    logic [WIDTH-1:0] MemReadData_MEM;
    
    // Pipeline MEM/WB
    logic [WIDTH-1:0] MemReadData_WB, ALUResult_WB;
    logic [4:0] Rd_WB;
    logic RegWrite_WB, MemtoReg_WB, unsigned_load_WB;
    
    // Etapa WB
    logic [WIDTH-1:0] WriteData_WB;
    
    // Extracción campos instrucción
    assign opcode = instruction_ID[6:0];
    assign Rd_ID = instruction_ID[11:7];
    assign func3 = instruction_ID[14:12];
    assign Rs1 = instruction_ID[19:15];
    assign Rs2 = instruction_ID[24:20];
    assign func7 = instruction_ID[31:25];
    
    //Data Hazard
    IDRawHazard #(.WIDTH(5)) hazard_detector (
    .WriteRegWB(Rd_WB),
    .Rs1ID(Rs1),
    .Rs2ID(Rs2),
    .RegWriteW(RegWrite_WB),
    .rst(rst),
    .IDHazardStall(IDhazardStall)
);
    lwHazardUnit #( .WIDTH(WIDTH2) ) lwHazard(
    .RegS1D(Rs1),     // Source register 1 in Decode
    .RegS2D(Rs2),     // Source register 2 in Decode
    .WriteRegE(Rd_EX),  // Write register in Memory stage
    .MeMtoRegE(MemtoReg_EX),              // MeMtoReg signal
    .rst(rst),                    // Reset signal
    .lwstall(lwstall)               // lwstall

);
// Raw Hazard Unit - Implementación con solo compuertas lógicas
RawHazardUnit #(.WIDTH(WIDTH2)) RawHazard(
   .RegS1E(Rs1_EX),     // Source register 1 in Execute
   .RegS2E(Rs2_EX),     // Source register 2 in Execute
   .WriteRegM(Rd_MEM),  // Write register in Memory stage
   .WriteRegWB(Rd_WB), // Write register in Writeback stage
   .RegWWB(RegWrite_WB),                 // Write enable for Writeback stage
   .RegWM(RegWrite_MEM),                  // Write enable for Memory stage
   .rst(rst),                    // Reset signal
   .src1(ForwardAE),            // Forward control for source 1
   .src2(ForwardBE)             // Forward control for source 2
);
ForwardMux #( .WIDTH(WIDTH)) ForwardMuxAE (
// Señales de entrada y salida
    .a(ReadData1_EX),
    .b(WriteData_WB),
    .c(ALUResult_MEM),
    .sel(ForwardAE), //bits de selcción de, va a decir cual de las 2 entradas pasa a la salida
    .out(ALU_a)

);

ForwardMux #( .WIDTH(WIDTH)) ForwardMuxBE (
// Señales de entrada y salida
    .a(ReadData2_EX),
    .b(WriteData_WB),
    .c(ALUResult_MEM),
    .sel(ForwardBE), //bits de selcción de, va a decir cual de las 2 entradas pasa a la salida
    .out(ForwardDataBE)

);


    // Etapa IF - Instruction Fetch
    
    // Contador de programa
    PC #(.WIDTH(WIDTH)) pc_unit (
        .clk(clk),
        .rst(rst),
        .StallF(StallF),
        .PC_in(PC_next),
        .PC_out(PC_current)
    );
    
    // PC + 4
    adder #(.WIDTH(WIDTH)) pc_adder (
        .a(PC_current),
        .b(32'd4),
        .out(PC_plus4)
    );
    
    // Memoria de instrucciones
    InstructionMemoryF #(.WIDTH(WIDTH), .DEPTH(DEPTH_IMEM)) instruction_memory (
        .rst(rst),
        .readAddress(PC_current),
        .instructionOut(instruction_IF)
    );
    
    // Registro IF/ID
    RegisterIF #(.WIDTH(WIDTH)) reg_if_id (
        .clk(clk),
        .rst(rst),
        .inst(instruction_IF),
        .pc(PC_plus4),
        .StallD(StallD),
        .PCSrcD(PCSrc_Branch),
        .inst_out(instruction_ID),
        .pc_out(PC_ID)
    );
    
    // Etapa ID - Instruction Decode
    
    // Unidad de control
    Control control_unit (
        .opcode(opcode),
        .func3(func3),
        .RegWrite(RegWrite_ID),
        .ALUSrc(ALUSrc_ID),
        .MemRead(MemRead_ID),
        .MemWrite(MemWrite_ID),
        .MemtoReg(MemtoReg_ID),
        .Branch(Branch_ID),
        .Jump(Jump_ID),
        .ALUOp(ALUOp_ID),
        .one_byte(one_byte_ID),
        .two_byte(two_byte_ID),
        .four_bytes(four_bytes_ID),
        .unsigned_load(unsigned_load_ID)
    );
    
    // Banco de registros
    RegisterFile #(.WIDTH(WIDTH), .ADDR_WIDTH(5)) register_file (
        .clk(clk),
        .rst(rst),
        .RegWrite(RegWrite_WB), // Desde etapa WB
        .Rs1(Rs1),
        .Rs2(Rs2),
        .Rd(Rd_WB),             // Desde etapa WB
        .WriteData(WriteData_WB), // Desde etapa WB
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );
    
    // Generador de inmediatos
    ImmediateGenerator #(.WIDTH(WIDTH)) imm_gen (
        .Opcode(opcode),
        .instruction(instruction_ID),
        .ImmExt(ImmExt_ID)
    );
    
    // Control ALU
    ALUControl alu_control (
        .ALUOp(ALUOp_ID),
        .func3(func3),
        .func7(func7),
        .ALUCtrl(ALUCtrl_ID)
    );
    
    // Registro ID/EX
    RegisterID #(.WIDTH(WIDTH), .ADDR_WIDTH(5)) reg_id_ex (
        .clk(clk),
        .rst(rst),
        .FlushE(FlushE),
        // PC
        .pc(PC_ID),
        .pc_out(PC_EX),
        // Control signals
        .ALUOp_in(ALUOp_ID),
        .ALUOp(ALUOp_EX),
        .ALUSrc_in(ALUSrc_ID),
        .ALUSrc_out(ALUSrc_EX),
        .Branch_in(Branch_ID),
        .Branch(Branch_EX),
        .Jump_in(Jump_ID),
        .Jump(Jump_EX),
        .one_byte_in(one_byte_ID),
        .one_byte(one_byte_EX),
        .two_byte_in(two_byte_ID),
        .two_byte(two_byte_EX),
        .four_bytes_in(four_bytes_ID),
        .four_bytes(four_bytes_EX),
        .MemRead_in(MemRead_ID),
        .MemRead(MemRead_EX),
        .MemWrite_in(MemWrite_ID),
        .MemWrite(MemWrite_EX),
        .RegWrite_in(RegWrite_ID),
        .RegWrite(RegWrite_EX),
        .MemtoReg_in(MemtoReg_ID),
        .MemtoReg(MemtoReg_EX),
        .unsigned_load_in(unsigned_load_ID),
        .unsigned_load(unsigned_load_EX),
        // Data
        .data1_in(ReadData1),
        .data1(ReadData1_EX),
        .data2_in(ReadData2),
        .data2(ReadData2_EX),
        .Imm_in(ImmExt_ID),
        .Imm(ImmExt_EX),
        .ALUCtrl_in(ALUCtrl_ID),
        .ALUCtrl(ALUCtrl_EX),
        .Rd_in(Rd_ID),
        .Rd(Rd_EX),
        .Rs1D(Rs1),
        .Rs1E(Rs1_EX),
        .Rs2D(Rs2),
        .Rs2E(Rs2_EX)
    );
    
    // Etapa EX - Execute
    
    // Mux fuente ALU

    
    Mux #(.WIDTH(WIDTH)) alu_src_mux (
        .a(ForwardDataBE),
        .b(ImmExt_EX),
        .sel(ALUSrc_EX),
        .out(ALU_b)
    );
    
    // ALU
    RVALU #(.WIDTH(WIDTH)) alu (
        .a(ALU_a),
        .b(ALU_b),
        .ALUCtrl(ALUCtrl_EX),
        .ALUResult(ALUResult_EX),
        .Zero(Zero_EX),
        .Comparison(Comparison_EX)
    );
    
    // Dirección branch
    adder #(.WIDTH(WIDTH)) branch_adder (
        .a(PC_ID),
        .b(ImmExt_ID),
        .out(PC_branch_target)
    );
    
    // Dirección jump
    adder #(.WIDTH(WIDTH)) jump_adder (
        .a((opcode == 7'b1100111) ? ReadData1_EX : PC_EX), // JALR vs JAL
        .b(ImmExt_EX),
        .out(PC_jump_target)
    );
    
    // Registro EX/MEM
    RegisterEx #(.WIDTH(WIDTH), .ADDR_WIDTH(5)) reg_ex_mem (
        .clk(clk),
        .rst(rst),
        // PC Branch
        .pcBranch(PC_branch_target),
        .pcBranch_out(PC_branch_MEM),
        // Control signals
        .Branch_in(Branch_EX),
        .Branch(Branch_MEM),
        .Jump_in(Jump_EX),
        .Jump(Jump_MEM),
        .one_byte_in(one_byte_EX),
        .one_byte(one_byte_MEM),
        .two_byte_in(two_byte_EX),
        .two_byte(two_byte_MEM),
        .four_bytes_in(four_bytes_EX),
        .four_bytes(four_bytes_MEM),
        .MemRead_in(MemRead_EX),
        .MemRead(MemRead_MEM),
        .MemWrite_in(MemWrite_EX),
        .MemWrite(MemWrite_MEM),
        .RegWrite_in(RegWrite_EX),
        .RegWrite(RegWrite_MEM),
        .MemtoReg_in(MemtoReg_EX),
        .MemtoReg(MemtoReg_MEM),
        .unsigned_load_in(unsigned_load_EX),
        .unsigned_load(unsigned_load_MEM),
        // Data
        .ALUResult_in(ALUResult_EX),
        .ALUResult(ALUResult_MEM),
        .Rd_in(Rd_EX),
        .Rd(Rd_MEM),
        .WriteData_in(ReadData2_EX),
        .WriteData(WriteData_MEM),
        .Comparison_in(Comparison_EX),
        .Comparison(Comparison_MEM)
    );
    
    // Etapa MEM - Memory Access
    
    // Memoria de datos
    DataMemory #(.WIDTH(WIDTH), .DEPTH(DEPTH_DMEM)) data_memory (
        .clk(clk),
        .rst(rst),
        .MemWrite(MemWrite_MEM),
        .MemRead(MemRead_MEM),
        .Address(ALUResult_MEM[DEPTH_DMEM-1:0]),
        .WriteData(WriteData_MEM),
        .one_byte(one_byte_MEM),
        .two_byte(two_byte_MEM),
        .four_bytes(four_bytes_MEM),
        .unsigned_load(unsigned_load_MEM),
        .ReadData(MemReadData_MEM)
    );
    
    // Registro MEM/WB
    RegisterWb #(.WIDTH(WIDTH), .ADDR_WIDTH(5)) reg_mem_wb (
        .clk(clk),
        .rst(rst),
        // Control signals
        .RegWrite_in(RegWrite_MEM),
        .RegWrite(RegWrite_WB),
        .MemtoReg_in(MemtoReg_MEM),
        .MemtoReg(MemtoReg_WB),
        .unsigned_load_in(unsigned_load_MEM),
        .unsigned_load(unsigned_load_WB),
        // Data
        .data_in(MemReadData_MEM),
        .data(MemReadData_WB),
        .ALUResult_in(ALUResult_MEM),
        .ALUResult(ALUResult_WB),
        .Rd_in(Rd_MEM),
        .Rd(Rd_WB)
    );
    
    // Etapa WB - Write Back
    
    // Mux Write Back
    logic [WIDTH-1:0] WriteData_temp1, WriteData_temp2;
    
    Mux #(.WIDTH(WIDTH)) writeback_mux1 (
        .a(ALUResult_WB),
        .b(MemReadData_WB),
        .sel(MemtoReg_WB),
        .out(WriteData_temp1)
    );
    
    Mux #(.WIDTH(WIDTH)) writeback_mux2 (
        .a(WriteData_temp1),
        .b(PC_ID), // PC+4 para JAL/JALR
        .sel(Jump_MEM), // Jump desde etapa MEM
        .out(WriteData_WB)
    );
    
    // Control PC
    
    // Control branch
    assign PCSrc_Branch = Branch_ID & EqualD;
    assign PCSrc_Jump = Jump_MEM;
    assign PCSrc = PCSrc_Jump | PCSrc_Branch;
    
    // Selección PC
    logic [WIDTH-1:0] PC_temp;
    Mux #(.WIDTH(WIDTH)) pc_branch_mux (
        .a(PC_plus4),
        .b(PC_branch_target),
        .sel(PCSrc_Branch),
        .out(PC_temp)
    );
    
    Mux #(.WIDTH(WIDTH)) pc_jump_mux (
        .a(PC_temp),
        .b(PC_jump_target), // Debe venir de etapa MEM para timing correcto
        .sel(PCSrc_Jump),
        .out(PC_next)
    );
    // Control de hazards
    Comparadores_mux comparadores_igualdad (
        .RD1(Mux_RD1),       
        .RD2(Mux_RD2),             
        .S0(EqualD)  
    ); 
    // Mux 1 comparadores 
    Mux #(.WIDTH(WIDTH)) mux1_comparadores (
        .a(ReadData1),
        .b(ALUResult_MEM),
        .sel(ForwardAD),
        .out(Mux_RD1)
    );
    // Mux 2 comparadores
    Mux #(.WIDTH(WIDTH)) mux2_comparadores (
        .a(ReadData2),
        .b(ALUResult_MEM),
        .sel(ForwardBD),
        .out(Mux_RD2)
    );

    comparador #(.WIDTH(WIDTH2)) compWRM_rsD (
        .rst(rst),
        .a(Rd_MEM),
        .b(Rs1),
        .y(wrm_eq_rsD)
    );

    Forward_AD Forward_AD (
        .rsD(Rs1),       
        .WRM_eq_rsD(wrm_eq_rsD),      
        .RegWriteM(RegWrite_MEM),       
        .ForwardAD(ForwardAD) 
    );

    comparador #(.WIDTH(WIDTH2)) compWRM_rtD (
        .rst(rst),
        .a(Rd_MEM),
        .b(Rs2),
        .y(wrm_eq_rtD)
    );
    
    Forward_BD Forward_BD (
        .rtD(Rs2),       
        .WRM_eq_rtD(wrm_eq_rtD),      
        .RegWriteM(RegWrite_MEM),       
        .ForwardBD(ForwardBD)     
    );
    
    comparador #(.WIDTH(WIDTH2)) compWRE_rsD (
        .rst(rst),
        .a(Rd_EX),
        .b(Rs1),
        .y(wre_eq_rsD)
    );

    comparador #(.WIDTH(WIDTH2)) compWRE_rtD (
        .rst(rst),
        .a(Rd_EX),
        .b(Rs2),
        .y(wre_eq_rtD)
    );

    branchstall branch_stall (
        .WRE_eq_rsD(wre_eq_rsD),
        .WRE_eq_rtD(wre_eq_rtD),
        .RegWriteE(RegWrite_EX),
        .BranchD(Branch_ID),
        .WRM_eq_rsD(wrm_eq_rsD),
        .WRM_eq_rtD(wrm_eq_rtD),
        .MemtoRegM(MemtoReg_MEM),
        .branch_stall(branchstall)
    );

    HazardUnit Hazard_unit (
        .IDHazardStall(IDhazardStall),
        .lwstall(lwstall),
        .branchstall(branchstall),
        .StallF(StallF),
        .StallD(StallD),
        .FlushE(FlushE)
    );
endmodule