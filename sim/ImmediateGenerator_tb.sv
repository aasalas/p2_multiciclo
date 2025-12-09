// Testbench corregido del ImmediateGenerator

`timescale 1ns/1ps

module ImmediateGenerator_tb;

    // Parámetros del testbench
    parameter WIDTH = 32;

    // Declaracion de las señales para el testbench.
    logic [6:0] Opcode;
    logic [WIDTH-1:0] instruction;
    logic [WIDTH-1:0] ImmExt;

    // Declaracion de las instancias para el testbench
    ImmediateGenerator #(.WIDTH(WIDTH)) uut (
        .Opcode(Opcode),
        .instruction(instruction),
        .ImmExt(ImmExt)
    );

    // Variables para verificación
    integer test_count = 0;
    integer pass_count = 0;
    
    // Task para verificar resultados con mejor formato
    task check_immediate;
        input [31:0] expected;
        input [31:0] actual;
        input [20*8:1] test_name;
        begin
            test_count = test_count + 1;
            if (expected == actual) begin
                $display("[PASS] %-25s: Expected=%0d (0x%08X), Got=%0d (0x%08X)", 
                        test_name, $signed(expected), expected, $signed(actual), actual);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %-25s: Expected=%0d (0x%08X), Got=%0d (0x%08X)", 
                        test_name, $signed(expected), expected, $signed(actual), actual);
                $display("       Instrucción: 0x%08X, Bits inmediato: %b", 
                        instruction, instruction[31:20]); // Mostrar bits relevantes
            end
            #1; // Pequeña pausa para claridad
        end
    endtask
    
    initial begin
        $display("=== TESTBENCH CORREGIDO: RISC-V Immediate Generator ===");
        $display("Verificando generación correcta de inmediatos con extensión de signo\n");
        
        // ====== TIPO I (Opcode = 0010011) ======
        $display("--- Pruebas Tipo I (Inmediato) - Opcode: 0010011 ---");
        $display("Formato I: imm[11:0] = instruction[31:20]");
        
        // Caso 1: addi x4, x6, 30 (positivo)
        // imm = 30 = 12'b000000011110
        instruction = 32'b000000011110_00110_000_00100_0010011;
        Opcode = 7'b0010011;
        #10;
        check_immediate(32'd30, ImmExt, "I-Type: +30");
        
        // Caso 2: addi x5, x7, -10 (negativo)
        // imm = -10 = 12'b111111110110 (complemento a 2)
        instruction = 32'b111111110110_00111_000_00101_0010011;
        Opcode = 7'b0010011;
        #10;
        check_immediate(-32'd10, ImmExt, "I-Type: -10");
        
        // Caso 3: addi x3, x8, 2047 (máximo positivo)
        // imm = 2047 = 12'b011111111111
        instruction = 32'b011111111111_01000_000_00011_0010011;
        Opcode = 7'b0010011;
        #10;
        check_immediate(32'd2047, ImmExt, "I-Type: +2047");
        
        // Caso 4: addi x2, x9, -2048 (mínimo negativo)
        // imm = -2048 = 12'b100000000000
        instruction = 32'b100000000000_01001_000_00010_0010011;
        Opcode = 7'b0010011;
        #10;
        check_immediate(-32'd2048, ImmExt, "I-Type: -2048");
        
        // ====== TIPO I LOAD (Opcode = 0000011) ======
        $display("\n--- Pruebas Tipo I Load - Opcode: 0000011 ---");
        
        // Caso 1: lw x4, 16(x5)
        // imm = 16 = 12'b000000010000
        instruction = 32'b000000010000_00101_010_00100_0000011;
        Opcode = 7'b0000011;
        #10;
        check_immediate(32'd16, ImmExt, "I-Load: +16");
        
        // Caso 2: lb x3, -20(x6)
        // imm = -20 = 12'b111111101100
        instruction = 32'b111111101100_00110_000_00011_0000011;
        Opcode = 7'b0000011;
        #10;
        check_immediate(-32'd20, ImmExt, "I-Load: -20");
        
        // ====== TIPO S (Opcode = 0100011) ======
        $display("\n--- Pruebas Tipo S (Store) - Opcode: 0100011 ---");
        $display("Formato S: imm[11:0] = {instruction[31:25], instruction[11:7]}");
        
        // Caso 1: sw x5, 8(x6) (offset positivo)
        // imm = 8 = 12'b000000001000 = {7'b0000000, 5'b01000}
        instruction = 32'b0000000_00101_00110_010_01000_0100011;
        Opcode = 7'b0100011;
        #10;
        check_immediate(32'd8, ImmExt, "S-Type: +8");
        
        // Caso 2: sb x7, -12(x8) (offset negativo)
        // imm = -12 = 12'b111111110100 = {7'b1111111, 5'b10100}
        instruction = 32'b1111111_00111_01000_000_10100_0100011;
        Opcode = 7'b0100011;
        #10;
        check_immediate(-32'd12, ImmExt, "S-Type: -12");
        
        // Caso 3: sw x1, 2047(x2) (máximo positivo)
        // imm = 2047 = 12'b011111111111 = {7'b0111111, 5'b11111}
        instruction = 32'b0111111_00001_00010_010_11111_0100011;
        Opcode = 7'b0100011;
        #10;
        check_immediate(32'd2047, ImmExt, "S-Type: +2047");
        
        // Caso 4: sw x3, -2048(x4) (mínimo negativo)
        // imm = -2048 = 12'b100000000000 = {7'b1000000, 5'b00000}
        instruction = 32'b1000000_00011_00100_010_00000_0100011;
        Opcode = 7'b0100011;
        #10;
        check_immediate(-32'd2048, ImmExt, "S-Type: -2048");
        
        // ====== TIPO B (Opcode = 1100011) ======
        $display("\n--- Pruebas Tipo B (Branch) - Opcode: 1100011 ---");
        $display("Formato B: imm[12:1] = {instruction[31], instruction[7], instruction[30:25], instruction[11:8]}");
        $display("Nota: Inmediato B siempre es múltiplo de 2 (LSB = 0)");
        
        // Caso 1: beq x4, x5, 8 (salto hacia adelante)
        // imm = 8 = 13'b0000000001000, imm[12:1] = 12'b000000000100
        // {imm[12], imm[10:5], imm[4:1], imm[11]} = {0, 000000, 0100, 0}
        instruction = 32'b0_000000_00101_00100_000_0100_0_1100011;
        Opcode = 7'b1100011;
        #10;
        check_immediate(32'd8, ImmExt, "B-Type: +8");
        
        // Caso 2: bne x6, x7, -4 (salto hacia atrás)
        // imm = -4 = 13'b1111111111100, imm[12:1] = 12'b111111111110
        // {imm[12], imm[10:5], imm[4:1], imm[11]} = {1, 111111, 1110, 1}
        instruction = 32'b1_111111_00111_00110_001_1110_1_1100011;
        Opcode = 7'b1100011; 
        #10;
        check_immediate(-32'd4, ImmExt, "B-Type: -4");
        
        // Caso 3: beq x1, x2, 4094 (máximo positivo)
        // imm = 4094 = 13'b0111111111110, imm[12:1] = 12'b011111111111
        instruction = 32'b0_111111_00010_00001_000_1111_1_1100011;
        Opcode = 7'b1100011;
        #10;
        check_immediate(32'd4094, ImmExt, "B-Type: +4094");
        
        // Caso 4: bne x3, x4, -4096 (mínimo negativo)
        // imm = -4096 = 13'b1000000000000, imm[12:1] = 12'b100000000000
        instruction = 32'b1_000000_00100_00011_001_0000_0_1100011;
        Opcode = 7'b1100011;
        #10;
        check_immediate(-32'd4096, ImmExt, "B-Type: -4096");
        
        // ====== TIPO U LUI (Opcode = 0110111) ======
        $display("\n--- Pruebas Tipo U (LUI) - Opcode: 0110111 ---");
        $display("Formato U: imm[31:12] = instruction[31:12], imm[11:0] = 0");
        
        // Caso 1: lui x4, 0x12345
        instruction = 32'b00010010001101000101_00100_0110111;
        Opcode = 7'b0110111;
        #10;
        check_immediate(32'h12345000, ImmExt, "U-LUI: 0x12345");
        
        // Caso 2: lui x5, 0x80000 (bit de signo en 1)
        instruction = 32'b10000000000000000000_00101_0110111;
        Opcode = 7'b0110111;
        #10;
        check_immediate(32'h80000000, ImmExt, "U-LUI: 0x80000");
        
        // ====== TIPO U AUIPC (Opcode = 0010111) ======
        $display("\n--- Pruebas Tipo U (AUIPC) - Opcode: 0010111 ---");
        
        // Caso 1: auipc x5, 0x1000
        instruction = 32'b00000001000000000000_00101_0010111;
        Opcode = 7'b0010111;
        #10;
        check_immediate(32'h01000000, ImmExt, "U-AUIPC: 0x1000");
        
        // Caso 2: auipc x1, 0xFFFFF (todos 1s)
        instruction = 32'b11111111111111111111_00001_0010111;
        Opcode = 7'b0010111;
        #10;
        check_immediate(32'hFFFFF000, ImmExt, "U-AUIPC: 0xFFFFF");
        
        // ====== TIPO J (Opcode = 1101111) ======
        $display("\n--- Pruebas Tipo J (Jump) - Opcode: 1101111 ---");
        $display("Formato J: imm[20:1] = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]}");
        $display("Nota: Inmediato J siempre es múltiplo de 2 (LSB = 0)");
        
        // Caso 1: jal x1, 16 (salto pequeño)
        // imm = 16 = 21'b000000000000000010000, imm[20:1] = 20'b00000000000000001000
        // {imm[20], imm[10:1], imm[11], imm[19:12]} = {0, 0000001000, 0, 00000000}
        instruction = 32'b0_0000001000_0_00000000_00001_1101111;
        Opcode = 7'b1101111;
        #10;
        check_immediate(32'd16, ImmExt, "J-Type: +16");
        
        // Caso 2: jal x2, -8 (salto negativo)
        // imm = -8 = 21'b111111111111111111000, imm[20:1] = 20'b11111111111111111100
        instruction = 32'b1_1111111100_1_11111111_00010_1101111;
        Opcode = 7'b1101111;
        #10;
        check_immediate(-32'd8, ImmExt, "J-Type: -8");
        
        // Caso 3: jal x3, 1048574 (máximo positivo)
        // imm = 1048574 = 21'b011111111111111111110
        instruction = 32'b0_1111111111_1_01111111_00011_1101111;
        Opcode = 7'b1101111;
        #10;
        check_immediate(32'd1048574, ImmExt, "J-Type: +1048574");
        
        // Caso 4: jal x4, -1048576 (mínimo negativo)
        // imm = -1048576 = 21'b100000000000000000000
        instruction = 32'b1_0000000000_0_00000000_00100_1101111;
        Opcode = 7'b1101111;
        #10;
        check_immediate(-32'd1048576, ImmExt, "J-Type: -1048576");
        
        // ====== CASOS ESPECIALES ======
        $display("\n--- Casos Especiales (Inmediatos Cero) ---");
        
        // Inmediato cero en cada tipo
        instruction = 32'b000000000000_00000_000_00000_0010011; // addi x0, x0, 0
        Opcode = 7'b0010011;
        #10;
        check_immediate(32'd0, ImmExt, "I-Type: Zero");
        
        instruction = 32'b0000000_00000_00000_010_00000_0100011; // sw x0, 0(x0)
        Opcode = 7'b0100011;
        #10;
        check_immediate(32'd0, ImmExt, "S-Type: Zero");
        
        instruction = 32'b0_000000_00000_00000_000_0000_0_1100011; // beq x0, x0, 0
        Opcode = 7'b1100011;
        #10;
        check_immediate(32'd0, ImmExt, "B-Type: Zero");
        
        instruction = 32'b00000000000000000000_00000_0110111; // lui x0, 0
        Opcode = 7'b0110111;
        #10;
        check_immediate(32'd0, ImmExt, "U-Type: Zero");
        
        instruction = 32'b0_0000000000_0_00000000_00000_1101111; // jal x0, 0
        Opcode = 7'b1101111;
        #10;
        check_immediate(32'd0, ImmExt, "J-Type: Zero");
        
        // ====== CASOS ADICIONALES PARA MAYOR COBERTURA ======
        $display("\n--- Casos Adicionales ---");
        
        // Caso límite: I-type con bit 11 = 1 (signo negativo)
        instruction = 32'b100000000001_00001_000_00010_0010011; // addi x2, x1, -2047
        Opcode = 7'b0010011;
        #10;
        check_immediate(-32'd2047, ImmExt, "I-Type: -2047");
        
        // Caso U-type con valor intermedio
        instruction = 32'b01010101010101010101_00011_0110111; // lui x3, 0x55555
        Opcode = 7'b0110111;
        #10;
        check_immediate(32'h55555000, ImmExt, "U-Type: 0x55555");
        
        // ====== PRUEBA CON Opcode INVÁLIDO ======
        $display("\n--- Prueba con Opcode Inválido ---");
        instruction = 32'h12345678;
        Opcode = 7'b1111111; // Opcode inválido
        #10;
        check_immediate(32'd0, ImmExt, "Invalid Opcode");
        
        // Reporte final
        $display("\n" + "="*50);
        $display("=== RESUMEN DE PRUEBAS ===");
        $display("Total de pruebas: %d", test_count);
        $display("Pruebas exitosas: %d", pass_count);
        $display("Pruebas fallidas: %d", test_count - pass_count);
        $display("Porcentaje de éxito: %.1f%%", (pass_count * 100.0) / test_count);
        
        if (pass_count == test_count) begin
            $display("\n¡TODAS LAS PRUEBAS PASARON! ✓");
            $display("El generador de inmediatos funciona correctamente.");
        end else begin
            $display("\nALGUNAS PRUEBAS FALLARON - Revisar implementación ✗");
            $display("Verificar la lógica de generación de inmediatos.");
        end
        
        $display("="*50);
        $finish;
    end

    // Sistema de guardado de los resultados del testbench.
    initial begin
        $dumpfile("ImmediateGenerator_tb.vcd");
        $dumpvars(0, ImmediateGenerator_tb);
    end 

endmodule