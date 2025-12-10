
`timescale 1ns/1ps

module Control_tb#(parameter WIDTH = 32);
    // Señales de entrada
    logic [6:0] opcode;
    logic [2:0] func3;
    
    // Señales de salida
    logic RegWrite;
    logic ALUSrc;
    logic MemRead;
    logic MemWrite;
    logic MemtoReg;
    logic Branch;
    logic Jump;
    logic [1:0] ALUOp;
    logic one_byte;
    logic two_byte;
    logic four_bytes;
    logic unsigned_load;
    
    // Instanciar el módulo bajo prueba
    Control uut (
        .opcode(opcode),
        .func3(func3),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .Jump(Jump),
        .ALUOp(ALUOp),
        .one_byte(one_byte),
        .two_byte(two_byte),
        .four_bytes(four_bytes),
        .unsigned_load(unsigned_load)
    );
    
    // Variables para verificación
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;
    
    // Task para verificar resultados
    task verify_signals(
        input string test_name,
        input logic exp_RegWrite,
        input logic exp_ALUSrc,
        input logic exp_MemRead,
        input logic exp_MemWrite,
        input logic exp_MemtoReg,
        input logic exp_Branch,
        input logic exp_Jump,
        input logic [1:0] exp_ALUOp,
        input logic exp_one_byte,
        input logic exp_two_byte,
        input logic exp_four_bytes,
        input logic exp_unsigned_load
    );
        test_count++;
        #1; // Pequeno delay para estabilizacion
        
        if (RegWrite === exp_RegWrite &&
            ALUSrc === exp_ALUSrc &&
            MemRead === exp_MemRead &&
            MemWrite === exp_MemWrite &&
            MemtoReg === exp_MemtoReg &&
            Branch === exp_Branch &&
            Jump === exp_Jump &&
            ALUOp === exp_ALUOp &&
            one_byte === exp_one_byte &&
            two_byte === exp_two_byte &&
            four_bytes === exp_four_bytes &&
            unsigned_load === exp_unsigned_load) begin
            $display("✓ PASS: %s", test_name);
            pass_count++;
        end else begin
            $display("✗ FAIL: %s", test_name);
            $display("  Expected: RegWrite=%b ALUSrc=%b MemRead=%b MemWrite=%b MemtoReg=%b Branch=%b Jump=%b ALUOp=%b one_byte=%b two_byte=%b four_bytes=%b unsigned_load=%b",
                     exp_RegWrite, exp_ALUSrc, exp_MemRead, exp_MemWrite, exp_MemtoReg, exp_Branch, exp_Jump, exp_ALUOp, exp_one_byte, exp_two_byte, exp_four_bytes, exp_unsigned_load);
            $display("  Actual:   RegWrite=%b ALUSrc=%b MemRead=%b MemWrite=%b MemtoReg=%b Branch=%b Jump=%b ALUOp=%b one_byte=%b two_byte=%b four_bytes=%b unsigned_load=%b",
                     RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, Jump, ALUOp, one_byte, two_byte, four_bytes, unsigned_load);
            fail_count++;
        end
    endtask
    
    initial begin
        $display("=== Iniciando testbench para modulo Control ===");
        $display("");
        
        // Test 1: R-type instructions (ADD, SUB, AND, OR, etc.)
        $display("--- Probando instrucciones R-type ---");
        opcode = 7'b0110011;
        func3 = 3'b000; // No importa para R-type en este módulo
        verify_signals("R-type (ADD/SUB)", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b10, 1'b0, 1'b0, 1'b0, 1'b0);
        
        // Test 2: I-type Load instructions
        $display("--- Probando instrucciones Load (I-type) ---");
        opcode = 7'b0000011;
        
        // LB - Load Byte
        func3 = 3'b000;
        verify_signals("LB (Load Byte)", 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0);
        
        // LH - Load Halfword
        func3 = 3'b001;
        verify_signals("LH (Load Halfword)", 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1, 1'b0, 1'b0);
        
        // LW - Load Word
        func3 = 3'b010;
        verify_signals("LW (Load Word)", 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0);
        
        // LBU - Load Byte Unsigned
        func3 = 3'b100;
        verify_signals("LBU (Load Byte Unsigned)", 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b1);
        
        // LHU - Load Halfword Unsigned
        func3 = 3'b101;
        verify_signals("LHU (Load Halfword Unsigned)", 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1, 1'b0, 1'b1);
        
        // Test 3: I-type Immediate instructions
        $display("--- Probando instrucciones Immediate (I-type) ---");
        opcode = 7'b0010011;
        func3 = 3'b000; // ADDI como ejemplo
        verify_signals("ADDI (Add Immediate)", 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0, 1'b0, 1'b0);
        
        // Test 4: S-type Store instructions
        $display("--- Probando instrucciones Store (S-type) ---");
        opcode = 7'b0100011;
        
        // SB - Store Byte
        func3 = 3'b000;
        verify_signals("SB (Store Byte)", 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0);
        
        // SH - Store Halfword
        func3 = 3'b001;
        verify_signals("SH (Store Halfword)", 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1, 1'b0, 1'b0);
        
        // SW - Store Word
        func3 = 3'b010;
        verify_signals("SW (Store Word)", 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0);
        
        // Test 5: B-type Branch instructions
        $display("--- Probando instrucciones Branch (B-type) ---");
        opcode = 7'b1100011;
        func3 = 3'b000; // BEQ como ejemplo
        verify_signals("BEQ (Branch Equal)", 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0, 1'b0, 1'b0);
        
        // Test 6: U-type LUI
        $display("--- Probando instrucciones U-type ---");
        opcode = 7'b0110111;
        func3 = 3'b000; // No importa para LUI
        verify_signals("LUI (Load Upper Immediate)", 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);
        
        // Test 7: U-type AUIPC
        opcode = 7'b0010111;
        func3 = 3'b000; // No importa para AUIPC
        verify_signals("AUIPC (Add Upper Immediate to PC)", 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);
        
        // Test 8: J-type JAL
        $display("--- Probando instrucciones Jump ---");
        opcode = 7'b1101111;
        func3 = 3'b000; // No importa para JAL
        verify_signals("JAL (Jump and Link)", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);
        
        // Test 9: I-type JALR
        opcode = 7'b1100111;
        func3 = 3'b000; // JALR
        verify_signals("JALR (Jump and Link Register)", 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);
        
        // Test 10: Opcode invalido (debe mantener valores por defecto)
        $display("--- Probando opcode invalido ---");
        opcode = 7'b1111111;
        func3 = 3'b000;
        verify_signals("Opcode invalido", 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);
        
        // Test 11: func3 invalido para Load (debe usar default LW)
        $display("--- Probando func3 invalido en Load ---");
        opcode = 7'b0000011;
        func3 = 3'b111; // func3 invalido
        verify_signals("Load con func3 invalido (default LW)", 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0);
        
        // Test 12: func3 invalido para Store (debe usar default SW)
        $display("--- Probando func3 invalido en Store ---");
        opcode = 7'b0100011;
        func3 = 3'b111; // func3 invalido
        verify_signals("Store con func3 invalido (default SW)", 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0);
        
        // Mostrar resumen final
        $display("");
        $display("=== RESUMEN DE PRUEBAS ===");
        $display("Total de pruebas: %0d", test_count);
        $display("Pruebas exitosas: %0d", pass_count);
        $display("Pruebas fallidas: %0d", fail_count);
        
        if (fail_count == 0) begin
            $display(" TODAS LAS PRUEBAS PASARON!");
        end else begin
            $display("  Algunas pruebas fallaron. Revisar implementacion.");
        end
        
        $display("");
        $finish;
    end

    // Sistema de guardado de los resultados del testbench.
    initial begin
        $dumpfile("Control_tb.vcd");
        $dumpvars(0, Control_tb);
    end 

endmodule