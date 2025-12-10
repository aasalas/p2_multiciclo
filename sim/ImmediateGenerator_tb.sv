// Testbench corregido del ImmediateGenerator

`timescale 1ns/1ps

module ImmediateGenerator_tb;

    parameter WIDTH = 32;

    logic [6:0] Opcode;
    logic [WIDTH-1:0] instruction;
    logic [WIDTH-1:0] ImmExt;

    ImmediateGenerator #(.WIDTH(WIDTH)) uut (
        .Opcode(Opcode),
        .instruction(instruction),
        .ImmExt(ImmExt)
    );

    integer test_count = 0;
    integer pass_count = 0;
    
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
                $display("       Instruccion: 0x%08X, Bits inmediato: %b", 
                        instruction, instruction[31:20]);
            end
            #1; // Pequena pausa para claridad
        end
    endtask
    
    initial begin
        $display("=== TESTBENCH CORREGIDO: RISC-V Immediate Generator ===");
        $display("Verificando generacion correcta de inmediatos con extension de signo\n");
        
        $display("--- Pruebas Tipo I (Inmediato) - Opcode: 0010011 ---");
        $display("Formato I: imm[11:0] = instruction[31:20]");
        
        instruction = 32'b000000011110_00110_000_00100_0010011;
        Opcode = 7'b0010011;
        #10;
        check_immediate(32'd30, ImmExt, "I-Type: +30");
        
        instruction = 32'b111111110110_00111_000_00101_0010011;
        Opcode = 7'b0010011;
        #10;
        check_immediate(-32'd10, ImmExt, "I-Type: -10");
        
        instruction = 32'b011111111111_01000_000_00011_0010011;
        Opcode = 7'b0010011;
        #10;
        check_immediate(32'd2047, ImmExt, "I-Type: +2047");
        
        instruction = 32'b100000000000_01001_000_00010_0010011;
        Opcode = 7'b0010011;
        #10;
        check_immediate(-32'd2048, ImmExt, "I-Type: -2048");
        
        $display("\n--- Pruebas Tipo I Load - Opcode: 0000011 ---");
        
        instruction = 32'b000000010000_00101_010_00100_0000011;
        Opcode = 7'b0000011;
        #10;
        check_immediate(32'd16, ImmExt, "I-Load: +16");
        
        instruction = 32'b111111101100_00110_000_00011_0000011;
        Opcode = 7'b0000011;
        #10;
        check_immediate(-32'd20, ImmExt, "I-Load: -20");
        
        $display("\n--- Pruebas Tipo S (Store) - Opcode: 0100011 ---");
        $display("Formato S: imm[11:0] = {instruction[31:25], instruction[11:7]}");
        
        instruction = 32'b0000000_00101_00110_010_01000_0100011;
        Opcode = 7'b0100011;
        #10;
        check_immediate(32'd8, ImmExt, "S-Type: +8");
        
        instruction = 32'b1111111_00111_01000_000_10100_0100011;
        Opcode = 7'b0100011;
        #10;
        check_immediate(-32'd12, ImmExt, "S-Type: -12");
        
        instruction = 32'b0111111_00001_00010_010_11111_0100011;
        Opcode = 7'b0100011;
        #10;
        check_immediate(32'd2047, ImmExt, "S-Type: +2047");
        
        instruction = 32'b1000000_00011_00100_010_00000_0100011;
        Opcode = 7'b0100011;
        #10;
        check_immediate(-32'd2048, ImmExt, "S-Type: -2048");
        
        $display("\n--- Pruebas Tipo B (Branch) - Opcode: 1100011 ---");
        $display("Formato B: imm[12:1] = {instruction[31], instruction[7], instruction[30:25], instruction[11:8]}");
        $display("Nota: Inmediato B siempre es multiplo de 2 (LSB = 0)");
        
        instruction = 32'b0_000000_00101_00100_000_0100_0_1100011;
        Opcode = 7'b1100011;
        #10;
        check_immediate(32'd8, ImmExt, "B-Type: +8");
        
        instruction = 32'b1_111111_00111_00110_001_1110_1_1100011;
        Opcode = 7'b1100011; 
        #10;
        check_immediate(-32'd4, ImmExt, "B-Type: -4");
        
        instruction = 32'b0_111111_00010_00001_000_1111_1_1100011;
        Opcode = 7'b1100011;
        #10;
        check_immediate(32'd4094, ImmExt, "B-Type: +4094");
        
        instruction = 32'b1_000000_00100_00011_001_0000_0_1100011;
        Opcode = 7'b1100011;
        #10;
        check_immediate(-32'd4096, ImmExt, "B-Type: -4096");
        
        $display("\n--- Pruebas Tipo U (LUI) - Opcode: 0110111 ---");
        $display("Formato U: imm[31:12] = instruction[31:12], imm[11:0] = 0");
        
        instruction = 32'b00010010001101000101_00100_0110111;
        Opcode = 7'b0110111;
        #10;
        check_immediate(32'h12345000, ImmExt, "U-LUI: 0x12345");
        
        instruction = 32'b10000000000000000000_00101_0110111;
        Opcode = 7'b0110111;
        #10;
        check_immediate(32'h80000000, ImmExt, "U-LUI: 0x80000");
        
        $display("\n--- Pruebas Tipo U (AUIPC) - Opcode: 0010111 ---");
        
        instruction = 32'b00000001000000000000_00101_0010111;
        Opcode = 7'b0010111;
        #10;
        check_immediate(32'h01000000, ImmExt, "U-AUIPC: 0x1000");
        
        instruction = 32'b11111111111111111111_00001_0010111;
        Opcode = 7'b0010111;
        #10;
        check_immediate(32'hFFFFF000, ImmExt, "U-AUIPC: 0xFFFFF");
        
        $display("\n--- Pruebas Tipo J (Jump) - Opcode: 1101111 ---");
        $display("Formato J: imm[20:1] = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]}");
        $display("Nota: Inmediato J siempre es multiplo de 2 (LSB = 0)");
        
        instruction = 32'b0_0000001000_0_00000000_00001_1101111;
        Opcode = 7'b1101111;
        #10;
        check_immediate(32'd16, ImmExt, "J-Type: +16");
        
        instruction = 32'b1_1111111100_1_11111111_00010_1101111;
        Opcode = 7'b1101111;
        #10;
        check_immediate(-32'd8, ImmExt, "J-Type: -8");
        
        instruction = 32'b0_1111111111_1_01111111_00011_1101111;
        Opcode = 7'b1101111;
        #10;
        check_immediate(32'd1048574, ImmExt, "J-Type: +1048574");
        
        instruction = 32'b1_0000000000_0_00000000_00100_1101111;
        Opcode = 7'b1101111;
        #10;
        check_immediate(-32'd1048576, ImmExt, "J-Type: -1048576");
        
        $display("\n--- Casos Especiales (Inmediatos Cero) ---");
        
        instruction = 32'b000000000000_00000_000_00000_0010011;
        Opcode = 7'b0010011;
        #10;
        check_immediate(32'd0, ImmExt, "I-Type: Zero");
        
        instruction = 32'b0000000_00000_00000_010_00000_0100011;
        Opcode = 7'b0100011;
        #10;
        check_immediate(32'd0, ImmExt, "S-Type: Zero");
        
        instruction = 32'b0_000000_00000_00000_000_0000_0_1100011;
        Opcode = 7'b1100011;
        #10;
        check_immediate(32'd0, ImmExt, "B-Type: Zero");
        
        instruction = 32'b00000000000000000000_00000_0110111;
        Opcode = 7'b0110111;
        #10;
        check_immediate(32'd0, ImmExt, "U-Type: Zero");
        
        instruction = 32'b0_0000000000_0_00000000_00000_1101111;
        Opcode = 7'b1101111;
        #10;
        check_immediate(32'd0, ImmExt, "J-Type: Zero");
        
        $display("\n--- Casos Adicionales ---");
        
        instruction = 32'b100000000001_00001_000_00010_0010011;
        Opcode = 7'b0010011;
        #10;
        check_immediate(-32'd2047, ImmExt, "I-Type: -2047");
        
        instruction = 32'b01010101010101010101_00011_0110111;
        Opcode = 7'b0110111;
        #10;
        check_immediate(32'h55555000, ImmExt, "U-Type: 0x55555");
        
        $display("\n--- Prueba con Opcode Invalido ---");
        instruction = 32'h12345678;
        Opcode = 7'b1111111;
        #10;
        check_immediate(32'd0, ImmExt, "Invalid Opcode");
        
        $display("\n" + "="*50);
        $display("=== RESUMEN DE PRUEBAS ===");
        $display("Total de pruebas: %d", test_count);
        $display("Pruebas exitosas: %d", pass_count);
        $display("Pruebas fallidas: %d", test_count - pass_count);
        $display("Porcentaje de exito: %.1f%%", (pass_count * 100.0) / test_count);
        
        if (pass_count == test_count) begin
            $display("\nTODAS LAS PRUEBAS PASARON!");
            $display("El generador de inmediatos funciona correctamente.");
        end else begin
            $display("\nALGUNAS PRUEBAS FALLARON - Revisar implementacion");
            $display("Verificar la logica de generacion de inmediatos.");
        end
        
        $display("="*50);
        $finish;
    end

    initial begin
        $dumpfile("ImmediateGenerator_tb.vcd");
        $dumpvars(0, ImmediateGenerator_tb);
    end 

endmodule