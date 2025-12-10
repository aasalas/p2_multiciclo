module RegisterID #(parameter WIDTH=32, parameter ADDR_WIDTH=5) (
    input clk, rst, FlushE, //Señales de control
    
    //PC
    input logic [WIDTH-1:0] pc, 
    output logic [WIDTH-1:0] pc_out,
    
    // Señales de control del datapath
    //Execution
    input logic [1:0] ALUOp_in,   // Tipo de operación para ALUControl
    output logic [1:0] ALUOp,     // Tipo de operación para ALUControl
    input logic ALUSrc_in,        // 0: Rs2, 1: Inmediato para ALU
    output logic ALUSrc_out,      // 0: Rs2, 1: Inmediato para ALU
    
    //Memory
    input logic Branch_in,        // Instrucción de branch
    output logic Branch,          // Instrucción de branch
    input logic Jump_in,          // Instrucción de jump
    output logic Jump,            // Instrucción de jump
    input logic one_byte_in,      // Para sb, lb, lbu
    output logic one_byte,        // Para sb, lb, lbu
    input logic two_byte_in,      // Para sh, lh, lhu
    output logic two_byte,        // Para sh, lh, lhu
    input logic four_bytes_in,    // Para sw, lw
    output logic four_bytes,      // Para sw, lw
    input logic MemRead_in,       // Leer de memoria
    output logic MemRead,         // Leer de memoria
    input logic MemWrite_in,      // Escribir a memoria  
    output logic MemWrite,        // Escribir a memoria  
    
    //WriteBack
    input logic RegWrite_in,      // Escribir en registro destino
    output logic RegWrite,        // Escribir en registro destino
    input logic MemtoReg_in,      // 0: ALU result, 1: Mem data a registro
    output logic MemtoReg,        // 0: ALU result, 1: Mem data a registro
    input logic unsigned_load_in, // Para lbu, lhu
    output logic unsigned_load,   // Para lbu, lhu

    // Datos e inmediatos
    input logic [WIDTH-1:0] Imm_in,  // immediate
    output logic [WIDTH-1:0] Imm,    // immediate

    input logic [3:0] ALUCtrl_in,    // Señal de control para ALU
    output logic [3:0] ALUCtrl,      // Señal de control para ALU

    input logic [WIDTH-1:0] data1_in, //Señales de información de los registros
    output logic [WIDTH-1:0] data1,

    input logic [WIDTH-1:0] data2_in,
    output logic [WIDTH-1:0] data2,

    // Direcciones de registros
    input logic [ADDR_WIDTH-1:0] Rd_in,    // Direccion de registro destino
    output logic [ADDR_WIDTH-1:0] Rd,      // Direccion de registro destino
    input logic [ADDR_WIDTH-1:0] Rs1D,     // Registro fuente 1 desde Decode
    output logic [ADDR_WIDTH-1:0] Rs1E,    // Registro fuente 1 hacia Execute
    input logic [ADDR_WIDTH-1:0] Rs2D,     // Registro fuente 2 desde Decode
    output logic [ADDR_WIDTH-1:0] Rs2E     // Registro fuente 2 hacia Execute
);

always_ff @(posedge clk or posedge rst)
begin
    if(rst) begin
        // Reset asíncrono - solo por rst
        pc_out <= {WIDTH{1'b0}};
        data1 <= {WIDTH{1'b0}};
        data2 <= {WIDTH{1'b0}};
        ALUOp <= 2'b0;
        ALUSrc_out <= 1'b0;
        Branch <= 1'b0;
        Jump <= 1'b0;
        one_byte <= 1'b0;
        two_byte <= 1'b0;
        four_bytes <= 1'b0;
        MemRead <= 1'b0;
        MemWrite <= 1'b0;
        RegWrite <= 1'b0;
        MemtoReg <= 1'b0;
        unsigned_load <= 1'b0;
        Imm <= {WIDTH{1'b0}};
        ALUCtrl <= 4'b0;
        Rd <= {ADDR_WIDTH{1'b0}};
        Rs1E <= {ADDR_WIDTH{1'b0}};
        Rs2E <= {ADDR_WIDTH{1'b0}};
    end
    else begin
        if(FlushE) begin
            // Flush síncrono 
            pc_out <= {WIDTH{1'b0}};
            data1 <= {WIDTH{1'b0}};
            data2 <= {WIDTH{1'b0}};
            ALUOp <= 2'b0;
            ALUSrc_out <= 1'b0;
            Branch <= 1'b0;
            Jump <= 1'b0;
            one_byte <= 1'b0;
            two_byte <= 1'b0;
            four_bytes <= 1'b0;
            MemRead <= 1'b0;
            MemWrite <= 1'b0;
            RegWrite <= 1'b0;
            MemtoReg <= 1'b0;
            unsigned_load <= 1'b0;
            Imm <= {WIDTH{1'b0}};
            ALUCtrl <= 4'b0;
            Rd <= {ADDR_WIDTH{1'b0}};
            Rs1E <= {ADDR_WIDTH{1'b0}};
            Rs2E <= {ADDR_WIDTH{1'b0}};
        end
        else begin
            // Operación normal - pasar todas las entradas a las salidas
            pc_out <= pc;
            data1 <= data1_in;
            data2 <= data2_in;
            ALUOp <= ALUOp_in;
            ALUSrc_out <= ALUSrc_in;
            Branch <= Branch_in;
            Jump <= Jump_in;
            one_byte <= one_byte_in;
            two_byte <= two_byte_in;
            four_bytes <= four_bytes_in;
            MemRead <= MemRead_in;
            MemWrite <= MemWrite_in;
            RegWrite <= RegWrite_in;
            MemtoReg <= MemtoReg_in;
            unsigned_load <= unsigned_load_in;
            Imm <= Imm_in;
            ALUCtrl <= ALUCtrl_in;
            Rd <= Rd_in;
            Rs1E <= Rs1D;
            Rs2E <= Rs2D;
        end
    end
end

endmodule