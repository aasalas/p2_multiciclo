`timescale 1ns / 1ps

module RVALU_tb#(parameter WIDTH=32);
    // Señales del testbench
    logic [WIDTH-1:0] a;
    logic [WIDTH-1:0] b;
    logic [3:0] ALUCtrl;
    logic [WIDTH-1:0] ALUResult;
    logic Zero;
    logic Comparison;
    
    // Variables para verificación
    logic [WIDTH-1:0] expected_result;
    logic expected_zero;
    logic expected_comparison;
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    
    // Instanciación del DUT (Device Under Test)
    RVALU #(.WIDTH(WIDTH)) dut (
        .a(a),
        .b(b),
        .ALUCtrl(ALUCtrl),
        .ALUResult(ALUResult),
        .Zero(Zero),
        .Comparison(Comparison)
    );
    
    // Función para verificar resultados
    task check_result(
        input [WIDTH-1:0] exp_result,
        input exp_zero,
        input exp_comparison,
        input string operation_name
    );
        test_count++;
        if (ALUResult === exp_result && Zero === exp_zero && Comparison === exp_comparison) begin
            $display("✓ PASS: %s - a=%h, b=%h, ALUCtrl=%b", operation_name, a, b, ALUCtrl);
            $display("    Result: %h, Zero: %b, Comparison: %b", ALUResult, Zero, Comparison);
            pass_count++;
        end else begin
            $display("✗ FAIL: %s - a=%h, b=%h, ALUCtrl=%b", operation_name, a, b, ALUCtrl);
            $display("    Expected: Result=%h, Zero=%b, Comparison=%b", exp_result, exp_zero, exp_comparison);
            $display("    Got:      Result=%h, Zero=%b, Comparison=%b", ALUResult, Zero, Comparison);
            fail_count++;
        end
        $display("");
    endtask
    
    // Función para calcular resultado esperado
    task calculate_expected(
        input [WIDTH-1:0] op_a,
        input [WIDTH-1:0] op_b,
        input [3:0] ctrl,
        output [WIDTH-1:0] exp_result,
        output exp_zero,
        output exp_comparison
    );
        exp_comparison = 1'b0; // Default
        
        case (ctrl)
            4'b0000: exp_result = op_a & op_b;                        // AND
            4'b0001: exp_result = op_a | op_b;                        // OR
            4'b0010: exp_result = $signed(op_a) + $signed(op_b);      // ADD
            4'b0011: exp_result = (op_a < op_b) ? 32'd1 : 32'd0;      // SLTU
            4'b0100: exp_result = ($signed(op_a) < $signed(op_b)) ? 32'd1 : 32'd0; // SLT
            4'b0110: exp_result = $signed(op_a) - $signed(op_b);      // SUB
            4'b1000: exp_result = op_a << op_b[4:0];                  // SLL
            4'b1001: exp_result = op_a ^ op_b;                        // XOR
            4'b1010: exp_result = op_a >> op_b[4:0];                  // SRL
            4'b1011: exp_result = $signed(op_a) >>> op_b[4:0];        // SRA
            
            // Branch operations
            4'b1100: begin // BEQ
                exp_result = {WIDTH{1'b0}};
                exp_comparison = ($signed(op_a) == $signed(op_b)) ? 1'b1 : 1'b0;
            end
            4'b1101: begin // BNE
                exp_result = {WIDTH{1'b0}};
                exp_comparison = ($signed(op_a) != $signed(op_b)) ? 1'b1 : 1'b0;
            end
            4'b1110: begin // BLT
                exp_result = {WIDTH{1'b0}};
                exp_comparison = ($signed(op_a) < $signed(op_b)) ? 1'b1 : 1'b0;
            end
            4'b1111: begin // BGE
                exp_result = {WIDTH{1'b0}};
                exp_comparison = ($signed(op_a) >= $signed(op_b)) ? 1'b1 : 1'b0;
            end
            4'b0101: begin // BLTU
                exp_result = {WIDTH{1'b0}};
                exp_comparison = (op_a < op_b) ? 1'b1 : 1'b0;
            end
            4'b0111: begin // BGEU
                exp_result = {WIDTH{1'b0}};
                exp_comparison = (op_a >= op_b) ? 1'b1 : 1'b0;
            end
            default: exp_result = $signed(op_a) + $signed(op_b);      // Default ADD
        endcase
        
        exp_zero = (exp_result == 0) ? 1'b1 : 1'b0;
    endtask
    
    // Test de una operación específica
    task test_operation(
        input [WIDTH-1:0] test_a,
        input [WIDTH-1:0] test_b,
        input [3:0] test_ctrl,
        input string op_name
    );
        a = test_a;
        b = test_b;
        ALUCtrl = test_ctrl;
        #1; // Pequeño delay para combinational logic
        
        calculate_expected(test_a, test_b, test_ctrl, expected_result, expected_zero, expected_comparison);
        check_result(expected_result, expected_zero, expected_comparison, op_name);
    endtask
    
    // Proceso principal de testing
    initial begin
        $display("=== Iniciando testbench para RVALU ===");
        $display("Ancho de datos: %d bits", WIDTH);
        $display("==========================================\n");
        
        // Test 1: Operaciones lógicas básicas
        $display("--- Test 1: Operaciones Logicas ---");
        test_operation(32'hAAAA5555, 32'h5555AAAA, 4'b0000, "AND");
        test_operation(32'hAAAA5555, 32'h5555AAAA, 4'b0001, "OR");
        test_operation(32'h12345678, 32'h87654321, 4'b1001, "XOR");
        
        // Test 2: Operaciones aritméticas
        $display("--- Test 2: Operaciones Aritmeticas ---");
        test_operation(32'd100, 32'd50, 4'b0010, "ADD positivos");
        test_operation(32'd100, 32'd150, 4'b0110, "SUB (100-150)");
        test_operation(-32'd50, 32'd25, 4'b0010, "ADD con negativo");
        test_operation(32'd0, 32'd0, 4'b0010, "ADD ceros (test Zero flag)");
        
        // Test 3: Operaciones de comparación (SLT/SLTU)
        $display("--- Test 3: Comparaciones SLT/SLTU ---");
        test_operation(32'd10, 32'd20, 4'b0100, "SLT (10 < 20)");
        test_operation(32'd20, 32'd10, 4'b0100, "SLT (20 < 10)");
        test_operation(-32'd10, 32'd5, 4'b0100, "SLT signed (-10 < 5)");
        test_operation(32'hFFFFFFFF, 32'd1, 4'b0011, "SLTU unsigned (0xFFFFFFFF < 1)");
        test_operation(32'hFFFFFFFF, 32'd1, 4'b0100, "SLT signed (0xFFFFFFFF < 1)");
        
        // Test 4: Operaciones de shift
        $display("--- Test 4: Operaciones de Shift ---");
        test_operation(32'h12345678, 32'd4, 4'b1000, "SLL shift left 4");
        test_operation(32'h12345678, 32'd4, 4'b1010, "SRL shift right 4");
        test_operation(32'h80000000, 32'd4, 4'b1011, "SRA arithmetic shift right 4");
        test_operation(32'h12345678, 32'd0, 4'b1000, "SLL shift 0");
        
        // Test 5: Operaciones de branch
        $display("--- Test 5: Operaciones de Branch ---");
        test_operation(32'd100, 32'd100, 4'b1100, "BEQ iguales");
        test_operation(32'd100, 32'd50, 4'b1100, "BEQ diferentes");
        test_operation(32'd100, 32'd50, 4'b1101, "BNE diferentes");
        test_operation(32'd100, 32'd100, 4'b1101, "BNE iguales");
        test_operation(32'd50, 32'd100, 4'b1110, "BLT (50 < 100)");
        test_operation(32'd100, 32'd50, 4'b1110, "BLT (100 < 50)");
        test_operation(32'd100, 32'd50, 4'b1111, "BGE (100 >= 50)");
        test_operation(32'd50, 32'd100, 4'b1111, "BGE (50 >= 100)");
        
        // Test 6: Branch unsigned
        $display("--- Test 6: Branch Unsigned ---");
        test_operation(32'hFFFFFFFF, 32'd1, 4'b0101, "BLTU unsigned (0xFFFFFFFF < 1)");
        test_operation(32'd1, 32'hFFFFFFFF, 4'b0101, "BLTU unsigned (1 < 0xFFFFFFFF)");
        test_operation(32'hFFFFFFFF, 32'd1, 4'b0111, "BGEU unsigned (0xFFFFFFFF >= 1)");
        test_operation(32'd1, 32'hFFFFFFFF, 4'b0111, "BGEU unsigned (1 >= 0xFFFFFFFF)");
        
        // Test 7: Casos edge y valores extremos
        $display("--- Test 7: Casos Extremos ---");
        test_operation(32'hFFFFFFFF, 32'd1, 4'b0010, "ADD overflow");
        test_operation(32'h80000000, 32'd1, 4'b0110, "SUB underflow");
        test_operation(32'hFFFFFFFF, 32'd31, 4'b1000, "SLL máximo shift");
        test_operation(32'hFFFFFFFF, 32'd31, 4'b1010, "SRL máximo shift");
        test_operation(32'h80000000, 32'd31, 4'b1011, "SRA máximo shift");
        
        // Test 8: Operación default
        $display("--- Test 8: Operacion Default ---");
        test_operation(32'd10, 32'd20, 4'b0001, "OR operation"); // Test normal

        
        // Test 9: Test del flag Zero
        $display("--- Test 9: Verificacion Flag Zero ---");
        test_operation(32'd0, 32'd0, 4'b0000, "AND que resulta en 0");
        test_operation(32'hFFFF0000, 32'h0000FFFF, 4'b0000, "AND que resulta en 0");
        test_operation(32'd50, 32'd50, 4'b0110, "SUB que resulta en 0");
        
        // Resumen final
        $display("\n==========================================");
        $display("=== RESUMEN DE RESULTADOS ===");
        $display("Total de tests: %d", test_count);
        $display("Tests exitosos: %d", pass_count);
        $display("Tests fallidos: %d", fail_count);
        $display("Porcentaje de exito: %.2f%%", (real'(pass_count) / real'(test_count)) * 100.0);
        
        if (fail_count == 0) begin
            $display(" TODOS LOS TESTS PASARON!");
        end else begin
            $display("  Algunos tests fallaron. Revisar implementacion.");
        end
        
        $display("==========================================");
        $finish;
    end

        // Sistema de guardado de los resultados del testbench.
    initial begin
        $dumpfile("RVALU_tb.vcd");
        $dumpvars(0, RVALU_tb);
    end 

endmodule