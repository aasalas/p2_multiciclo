// Banco de registros del procesador RISC-V
// Se utiliza para escribir, leer y guardar los valores de los registros del procesador
module RegisterFile #(parameter WIDTH=32, parameter ADDR_WIDTH=5) (
    // Señales de entrada y salida
    input logic clk, rst, 
    input logic RegWrite,                           // Señal de control para escribir
    input logic [ADDR_WIDTH-1:0] Rs1, Rs2, Rd,    // Direcciones de registros fuente y destino
    input logic [WIDTH-1:0] WriteData,             // Dato a escribir
    output logic [WIDTH-1:0] ReadData1, ReadData2  // Datos leídos de Rs1 y Rs2
);

    // Banco de 32 registros de 32 bits cada uno (RISC-V estándar)
    logic [WIDTH-1:0] Registers [31:0];

    // Escritura síncrona
    always_ff @(posedge clk) begin
        if (rst) begin
            // Reset: todos los registros a 0
            for (int i = 0; i < 32; i++) begin
                Registers[i] <= {WIDTH{1'b0}};
            end
        end
        else begin
            // Escribir solo si RegWrite está activo y no es el registro x0
            if (RegWrite && (Rd != 5'b00000)) begin
                Registers[Rd] <= WriteData;
            end
        end
    end

    // Lectura combinacional (asíncrona)
    always_comb begin
        // ReadData1: Si Rs1 es x0, retorna 0, sino retorna el contenido del registro
        ReadData1 = (Rs1 == 5'b00000) ? {WIDTH{1'b0}} : Registers[Rs1];
        
        // ReadData2: Si Rs2 es x0, retorna 0, sino retorna el contenido del registro  
        ReadData2 = (Rs2 == 5'b00000) ? {WIDTH{1'b0}} : Registers[Rs2];
    end

endmodule