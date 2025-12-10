module RegisterEx #(parameter WIDTH=32, parameter ADDR_WIDTH=5) (
    input clk, rst, //Señales de control
    //PC
    input logic [WIDTH-1:0] pcBranch,
    output logic [WIDTH-1:0] pcBranch_out, 
    // Señales de control del datapath
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

    input logic [WIDTH-1:0] ALUResult_in,
    output logic [WIDTH-1:0] ALUResult,

    input logic [ADDR_WIDTH-1:0] Rd_in,       // Direccion de registro destino
    output logic [ADDR_WIDTH-1:0] Rd,         // Direccion de registro destino

    input logic [WIDTH-1:0] WriteData_in,     // Dato a escribir
    output logic [WIDTH-1:0] WriteData,       // Dato a escribir

    input logic Comparison_in,                 // bit de comparacion (zero) de la ALU
    output logic Comparison                    // bit de comparacion (zero) de la ALU
);

always_ff @(posedge clk or posedge rst)
begin
    if(rst) begin
        // Reset todas las salidas a 0
        pcBranch_out <= {WIDTH{1'b0}};
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
        ALUResult <= {WIDTH{1'b0}};
        Rd <= {ADDR_WIDTH{1'b0}};
        WriteData <= {WIDTH{1'b0}};
        Comparison <= 1'b0;
    end
    else begin
        // En flanco positivo, pasar todas las entradas a las salidas
        pcBranch_out <= pcBranch;
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
        ALUResult <= ALUResult_in;
        Rd <= Rd_in;
        WriteData <= WriteData_in;
        Comparison <= Comparison_in;
    end
end

endmodule