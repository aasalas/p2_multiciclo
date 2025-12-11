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

$readmemh("hazard_raw1.mem", Memory); 
// Forwarding desde etapa EX (resultado de ALU se envia a siguiente instrucción)
// addi x1, x0, 10     # x1 = 10
// add x2, x1, x5      # x2 = x1 + x5 (RAW hazard: x1 se usa inmediatamente)
// add x3, x2, x0      # x3 = x2 + 0

//$readmemh("hazard_raw2.mem", Memory); 
// Forwarding desde etapa MEM (datos de memoria se reutilizan)
// addi x6, x0, 1      # x6 = 1
// sw x6, 0(x0)        # Mem[0] = x6
// lw x7, 0(x0)        # x7 = Mem[0] (lee lo que acaba de escribir)


//$readmemh("hazard_load_use.mem", Memory);
// Load-Use hazard requiere 1 ciclo de stall porque el dato no está listo en EX
// lw x4, 0(x0)        # x4 = Mem[0] (carga en MEM)
// add x5, x4, x0      # x5 = x4 + 0 (usa x4 inmediatamente - STALL!)
// nop                 # (instrucción de relleno)

//$readmemh("hazard_control.mem", Memory);
//  Control hazard con salto. Las instrucciones en IF/ID se descartan (flush)
// addi x9, x0, 5      # x9 = 5
// beq x9, x9, salto       # if (x9 == x9) PC += 4 (BRANCH TOMADO - FLUSH!)
// addi x10, x0, 1     # (se descarta)
// salto:
// addi x11, x0, 100   # (destino del salto)
    end

endmodule