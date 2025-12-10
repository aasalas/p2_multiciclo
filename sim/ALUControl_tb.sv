`timescale 1ns / 1ps

module ALUControl_tb;

    // Senales de entrada
    logic [1:0] ALUOp;
    logic [2:0] func3;
    logic [6:0] func7;
    
    // Senal de salida
    logic [3:0] ALUCtrl;
    
    // Instanciar el modulo bajo prueba
    ALUControl uut (
        .ALUOp(ALUOp),
        .func3(func3),
        .func7(func7),
        .ALUCtrl(ALUCtrl)
    );
    
    // Variables para verificacion
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;
    
    // Task para verificar resultados
    task verify_alucontrol(
        input string test_name,
        input logic [3:0] expected_ctrl
    );
        test_count++;
        #1; // Pequeno delay para estabilizacion
        
        if (ALUCtrl === expected_ctrl) begin
            $display("✓ PASS: %s - ALUCtrl = %b", test_name, ALUCtrl);
            pass_count++;
        end else begin
            $display("✗ FAIL: %s", test_name);
            $display("  Expected: ALUCtrl = %b", expected_ctrl);
            $display("  Actual:   ALUCtrl = %b", ALUCtrl);
            fail_count++;
        end
    endtask
    
    initial begin
        $display("=== Iniciando testbench para modulo ALUControl ===");
        $display("");
        
        // Test ALUOp = 00 (Load/Store/LUI/AUIPC/JAL/JALR)
        $display("--- Probando ALUOp = 00 (Load/Store/Immediate Upper) ---");
        ALUOp = 2'b00;
        func3 = 3'b000; // No importa
        func7 = 7'b0000000; // No importa
        verify_alucontrol("Load/Store/LUI/AUIPC", 4'b0010); // ADD
        
        // Test ALUOp = 01 (Branch instructions)
        $display("--- Probando ALUOp = 01 (Branch comparisons) ---");
        ALUOp = 2'b01;
        
        func3 = 3'b000; // BEQ
        verify_alucontrol("BEQ", 4'b1100);
        
        func3 = 3'b001; // BNE
        verify_alucontrol("BNE", 4'b1101);
        
        func3 = 3'b100; // BLT
        verify_alucontrol("BLT", 4'b1110);
        
        func3 = 3'b101; // BGE
        verify_alucontrol("BGE", 4'b1111);
        
        func3 = 3'b110; // BLTU
        verify_alucontrol("BLTU", 4'b0101);
        
        func3 = 3'b111; // BGEU
        verify_alucontrol("BGEU", 4'b0111);
        
        func3 = 3'b010; // func3 invalido para branch
        verify_alucontrol("Branch invalido (default BEQ)", 4'b1100);
        
        // Test ALUOp = 10 (R-type instructions)
        $display("--- Probando ALUOp = 10 (R-type operations) ---");
        ALUOp = 2'b10;
        
        // ADD
        func3 = 3'b000;
        func7 = 7'b0000000;
        verify_alucontrol("ADD", 4'b0010);
        
        // SUB
        func3 = 3'b000;
        func7 = 7'b0100000;
        verify_alucontrol("SUB", 4'b0110);
        
        // SLL
        func3 = 3'b001;
        func7 = 7'b0000000; // No importa para SLL
        verify_alucontrol("SLL", 4'b1000);
        
        // SLT
        func3 = 3'b010;
        verify_alucontrol("SLT", 4'b0100);
        
        // SLTU
        func3 = 3'b011;
        verify_alucontrol("SLTU", 4'b0011);
        
        // XOR
        func3 = 3'b100;
        verify_alucontrol("XOR", 4'b1001);
        
        // SRL
        func3 = 3'b101;
        func7 = 7'b0000000;
        verify_alucontrol("SRL", 4'b1010);
        
        // SRA
        func3 = 3'b101;
        func7 = 7'b0100000;
        verify_alucontrol("SRA", 4'b1011);
        
        // OR
        func3 = 3'b110;
        verify_alucontrol("OR", 4'b0001);
        
        // AND
        func3 = 3'b111;
        verify_alucontrol("AND", 4'b0000);
        
        // Test ALUOp = 11 (I-type immediate instructions)
        $display("--- Probando ALUOp = 11 (I-type immediate) ---");
        ALUOp = 2'b11;
        
        // ADDI
        func3 = 3'b000;
        func7 = 7'b0000000; // No importa para ADDI
        verify_alucontrol("ADDI", 4'b0010);
        
        // SLLI
        func3 = 3'b001;
        verify_alucontrol("SLLI", 4'b1000);
        
        // SLTI
        func3 = 3'b010;
        verify_alucontrol("SLTI", 4'b0100);
        
        // SLTIU
        func3 = 3'b011;
        verify_alucontrol("SLTIU", 4'b0011);
        
        // XORI
        func3 = 3'b100;
        verify_alucontrol("XORI", 4'b1001);
        
        // SRLI
        func3 = 3'b101;
        func7 = 7'b0000000;
        verify_alucontrol("SRLI", 4'b1010);
        
        // SRAI
        func3 = 3'b101;
        func7 = 7'b0100000;
        verify_alucontrol("SRAI", 4'b1011);
        
        // ORI
        func3 = 3'b110;
        verify_alucontrol("ORI", 4'b0001);
        
        // ANDI
        func3 = 3'b111;
        verify_alucontrol("ANDI", 4'b0000);
        
        // Test casos edge
        $display("--- Probando casos edge ---");
        
        // ALUOp invalido
        ALUOp = 2'b00; // Reset a valor valido primero
        #1;
        ALUOp = 2'bxx; // Valor invalido
        func3 = 3'b000;
        func7 = 7'b0000000;
        verify_alucontrol("ALUOp invalido", 4'b0010); // Default ADD
        
        // func3 invalido para R-type
        ALUOp = 2'b10;
        func3 = 3'bxxx;
        verify_alucontrol("R-type func3 invalido", 4'b0010); // Default ADD
        
        // func3 invalido para I-type
        ALUOp = 2'b11;
        func3 = 3'bxxx;
        verify_alucontrol("I-type func3 invalido", 4'b0010); // Default ADD
        
        // Mostrar resumen final
        $display("");
        $display("=== RESUMEN DE PRUEBAS ALUControl ===");
        $display("Total de pruebas: %0d", test_count);
        $display("Pruebas exitosas: %0d", pass_count);
        $display("Pruebas fallidas: %0d", fail_count);
        
        if (fail_count == 0) begin
            $display(" TODAS LAS PRUEBAS DE ALUControl PASARON!");
        end else begin
            $display("  Algunas pruebas de ALUControl fallaron.");
        end
        
        $display("");
        $finish;
    end
    // Sistema de guardado de los resultados del testbench.
    initial begin
        $dumpfile("ALUControl_tb.vcd");
        $dumpvars(0, ALUControl_tb);
    end 
endmodule