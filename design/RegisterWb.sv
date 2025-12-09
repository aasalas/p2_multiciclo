module RegisterWb #(parameter WIDTH=32, parameter ADDR_WIDTH=5) (
    input clk, rst, //Señales de control
    // Señales de control del datapath
    //WriteBack
    input logic RegWrite_in,      // Escribir en registro destino
    output logic RegWrite,        // Escribir en registro destino
    input logic MemtoReg_in,      // 0: ALU result, 1: Mem data a registro
    output logic MemtoReg,        // 0: ALU result, 1: Mem data a registro
    input logic unsigned_load_in, // Para lbu, lhu
    output logic unsigned_load,   // Para lbu, lhu

    input logic [WIDTH-1:0] data_in,       // para load de datos de memoria
    output logic [WIDTH-1:0] data,         // para load de datos de memoria

    input logic [WIDTH-1:0] ALUResult_in,  // Resultado de ALU
    output logic [WIDTH-1:0] ALUResult,    // Resultado de ALU
    
    input logic [ADDR_WIDTH-1:0] Rd_in,    // Direccion de registro destino
    output logic [ADDR_WIDTH-1:0] Rd       // Direccion de registro destino
);

always_ff @(posedge clk or posedge rst)
begin
    if(rst) begin
        // Reset todas las salidas a 0
        RegWrite <= 1'b0;
        MemtoReg <= 1'b0;
        unsigned_load <= 1'b0;
        data <= {WIDTH{1'b0}};
        ALUResult <= {WIDTH{1'b0}};
        Rd <= {ADDR_WIDTH{1'b0}};
    end
    else begin
        // En flanco positivo, pasar todas las entradas a las salidas
        RegWrite <= RegWrite_in;
        MemtoReg <= MemtoReg_in;
        unsigned_load <= unsigned_load_in;
        data <= data_in;
        ALUResult <= ALUResult_in;
        Rd <= Rd_in;
    end
end

endmodule