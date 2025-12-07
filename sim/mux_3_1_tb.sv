`timescale 1ns/1ps

module mux_3_1_tb;

    logic [31:0] in0, in1, in2;
    logic [1:0]  sel;
    logic [31:0] out;

    // Instanciar el DUT
    mux_3_1 dut (
        .in0(in0),
        .in1(in1),
        .in2(in2),
        .sel(sel),
        .out(out)
    );

    initial begin
        $display("=== Test MUX 3:1 ===");
        
        // Inicializar entradas
        in0 = 32'hAAAA_AAAA;
        in1 = 32'h5555_5555;
        in2 = 32'hFFFF_0000;
        
        // Test 1: sel = 00, debería seleccionar in0
        sel = 2'b00;
        #10;
        $display("Test 1 - sel=00: in0=%h, in1=%h, in2=%h, out=%h (esperado: %h)", 
                 in0, in1, in2, out, in0);
        assert(out == in0) else $error("Fallo: out debería ser in0");
        
        // Test 2: sel = 01, debería seleccionar in1
        sel = 2'b01;
        #10;
        $display("Test 2 - sel=01: in0=%h, in1=%h, in2=%h, out=%h (esperado: %h)", 
                 in0, in1, in2, out, in1);
        assert(out == in1) else $error("Fallo: out debería ser in1");
        
        // Test 3: sel = 10, debería seleccionar in2
        sel = 2'b10;
        #10;
        $display("Test 3 - sel=10: in0=%h, in1=%h, in2=%h, out=%h (esperado: %h)", 
                 in0, in1, in2, out, in2);
        assert(out == in2) else $error("Fallo: out debería ser in2");
        
        // Test 4: sel = 11, caso default (debería ser 0)
        sel = 2'b11;
        #10;
        $display("Test 4 - sel=11: in0=%h, in1=%h, in2=%h, out=%h (esperado: 00000000)", 
                 in0, in1, in2, out);
        assert(out == 32'h0000_0000) else $error("Fallo: out debería ser 0 (default)");
        
        // Test 5: Cambiar valores y volver a probar
        in0 = 32'h1111_1111;
        in1 = 32'h2222_2222;
        in2 = 32'h3333_3333;
        
        sel = 2'b00;
        #10;
        $display("Test 5 - sel=00: out=%h (esperado: %h)", out, in0);
        assert(out == in0) else $error("Fallo: out debería ser in0");
        
        sel = 2'b01;
        #10;
        $display("Test 6 - sel=01: out=%h (esperado: %h)", out, in1);
        assert(out == in1) else $error("Fallo: out debería ser in1");
        
        sel = 2'b10;
        #10;
        $display("Test 7 - sel=10: out=%h (esperado: %h)", out, in2);
        assert(out == in2) else $error("Fallo: out debería ser in2");
        
        $display("\n=== Todos los tests completados ===\n");
        $finish;
    end

endmodule
