module RegisterIF #(parameter WIDTH=32) (
    input clk, rst,                    // Señales de control
    input logic [WIDTH-1:0] inst,     // Entrada de instrucción 
    input logic [WIDTH-1:0] pc,       // Entrada de PC
    input logic StallD,
    input logic PCSrcD,
    output logic [WIDTH-1:0] inst_out, // Salida de instrucción
    output logic [WIDTH-1:0] pc_out   // Salida de PC
);

always_ff @(posedge clk or posedge rst)
begin
    if(rst) begin
        // Reset asíncrono - solo por rst
        inst_out <= 32'b0; 
        pc_out <= 32'b0; 
    end
    else begin
        if(PCSrcD) begin
            // Flush - insertar NOP
            inst_out <= 32'b0; 
            pc_out <= 32'b0; 
        end
        else if (~StallD) begin
            // Operación normal - actualizar registros
            inst_out <= inst;  
            pc_out <= pc;      
        end
        // Si StallD está activo, mantener valores actuales (no hacer nada)
    end
end 

endmodule