// Memoria de Instrucciones del procesador, usa un archivo para cargar las instrucciones
module InstructionMemoryF #(parameter WIDTH=32, parameter DEPTH=64) ( 
    input logic rst,
    input logic [WIDTH-1:0] readAddress,
    output logic [WIDTH-1:0] instructionOut
);

    logic [WIDTH-1:0] Memory[0:DEPTH-1];

    // Lectura secuencial
    always_comb begin
        if (rst) 
            instructionOut = 32'h00000013; // NOP instruction en reset
        else if ((readAddress >> 2) < DEPTH)
            instructionOut = Memory[readAddress >> 2];
        else
            instructionOut = 32'h00000013; // NOP para direcciones inválidas
    end

    // Inicialización desde archivo
    initial begin
        $readmemh("instructions.mem", Memory); // Carga desde archivo hexadecimal
    end

endmodule