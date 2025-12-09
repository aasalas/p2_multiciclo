// Módulo de memoria de datos mejorado para procesador RISC-V
// Soporta accesos de 1, 2 y 4 bytes con organización byte-addressable
// Optimizado específicamente para Yosys
module DataMemory #(parameter WIDTH=32, parameter DEPTH=12) ( // Reducido a 4KB para evitar problemas de síntesis
    // Señales de entrada y salida
    input logic clk, rst, 
    input logic MemWrite, MemRead,              // Señales de control para escribir y leer
    input logic [DEPTH-1:0] Address,            // Dirección de memoria (byte address)
    input logic [WIDTH-1:0] WriteData,          // Dato a escribir
    input logic one_byte,                       // Para sb, lb, lbu
    input logic two_byte,                       // Para sh, lh, lhu  
    input logic four_bytes,                     // Para sw, lw
    input logic unsigned_load,                  // Para lbu, lhu (extensión sin signo)
    output logic [WIDTH-1:0] ReadData           // Dato leído
);
    
    // Memoria de datos organizada por bytes
    logic [7:0] DataMem [2**DEPTH-1:0];
    
    // Señales intermedias para lectura -
    logic [7:0] mem_byte;
    logic [15:0] mem_halfword;
    logic [31:0] mem_word;
    
    // Señales de extensión 
    logic [31:0] byte_signed, byte_unsigned;
    logic [31:0] halfword_signed, halfword_unsigned;
    
    // Señales de control interno
    logic valid_address;
    logic valid_halfword_address;
    logic valid_word_address;
    
    // Validación de direcciones 
    assign valid_address = (Address < 2**DEPTH);
    assign valid_halfword_address = (Address + 1 < 2**DEPTH);
    assign valid_word_address = (Address + 3 < 2**DEPTH);
    
    // Lectura de memoria 
    assign mem_byte = DataMem[Address];
    assign mem_halfword = {DataMem[Address + 1], DataMem[Address]};
    assign mem_word = {DataMem[Address + 3], DataMem[Address + 2], 
                       DataMem[Address + 1], DataMem[Address]};
    
    // Extensiones de signo y cero 
    assign byte_signed = {{24{mem_byte[7]}}, mem_byte};
    assign byte_unsigned = {24'h000000, mem_byte};
    assign halfword_signed = {{16{mem_halfword[15]}}, mem_halfword};
    assign halfword_unsigned = {16'h0000, mem_halfword};

    int i;
    initial begin
    for (int i = 0; i < DEPTH; i++) begin
        DataMem[i] = 0; // Initialize memory to zero
    end
    
    end
    // Escritura síncrona - mantenida simple para Yosys
    always_ff @(posedge clk) begin
        if (!rst && MemWrite && valid_address) begin
            case ({four_bytes, two_byte, one_byte})
                3'b001: begin // sb - store byte
                    DataMem[Address] <= WriteData[7:0];
                end
                3'b010: begin // sh - store halfword
                    if (valid_halfword_address) begin
                        DataMem[Address]     <= WriteData[7:0];
                        DataMem[Address + 1] <= WriteData[15:8];
                    end
                end
                3'b100: begin // sw - store word
                    if (valid_word_address) begin
                        DataMem[Address]     <= WriteData[7:0];
                        DataMem[Address + 1] <= WriteData[15:8];
                        DataMem[Address + 2] <= WriteData[23:16];
                        DataMem[Address + 3] <= WriteData[31:24];
                    end
                end
                default: begin
                    // No operation - Yosys optimiza away este caso
                end
            endcase
        end
    end
    
    // Lectura combinacional 
    always_comb begin
        if (rst) begin
            ReadData = 32'h00000000;
        end
        else if (MemRead && valid_address) begin
            case ({four_bytes, two_byte, one_byte})
                3'b001: begin // lb/lbu - load byte
                    ReadData = unsigned_load ? byte_unsigned : byte_signed;
                end
                3'b010: begin // lh/lhu - load halfword
                    if (valid_halfword_address) begin
                        ReadData = unsigned_load ? halfword_unsigned : halfword_signed;
                    end else begin
                        ReadData = 32'h00000000;
                    end
                end
                3'b100: begin // lw - load word
                    if (valid_word_address) begin
                        ReadData = mem_word;
                    end else begin
                        ReadData = 32'h00000000;
                    end
                end
                default: begin
                    ReadData = 32'h00000000;
                end
            endcase
        end
        else begin
            ReadData = 32'h00000000;
        end
    end

endmodule