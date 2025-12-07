`timescale 1ns/1ps

module mux_2_1_tb;

    logic [31:0] in0, in1;
    logic        sel;
    logic [31:0] out;

    // Instanciar el DUT
    mux_2_1 dut (
        .in0(in0),
        .in1(in1),
        .sel(sel),
        .out(out)
    );

    initial begin
        $display("=== Test MUX 2:1 ===");
        
        // Test 1: sel = 0, debería seleccionar in0
        in0 = 32'hAAAA_AAAA;
        in1 = 32'h5555_5555;
        sel = 0;
        #10;
        $display("Test 1 - sel=0: in0=%h, in1=%h, out=%h (esperado: %h)", 
                 in0, in1, out, in0);
        assert(out == in0) else $error("Fallo: out debería ser in0");
        
        // Test 2: sel = 1, debería seleccionar in1
        sel = 1;
        #10;
        $display("Test 2 - sel=1: in0=%h, in1=%h, out=%h (esperado: %h)", 
                 in0, in1, out, in1);
        assert(out == in1) else $error("Fallo: out debería ser in1");
        
        // Test 3: Cambiar valores y probar sel = 0
        in0 = 32'h1234_5678;
        in1 = 32'h9ABC_DEF0;
        sel = 0;
        #10;
        $display("Test 3 - sel=0: in0=%h, in1=%h, out=%h (esperado: %h)", 
                 in0, in1, out, in0);
        assert(out == in0) else $error("Fallo: out debería ser in0");
        
        // Test 4: sel = 1
        sel = 1;
        #10;
        $display("Test 4 - sel=1: in0=%h, in1=%h, out=%h (esperado: %h)", 
                 in0, in1, out, in1);
        assert(out == in1) else $error("Fallo: out debería ser in1");
        
        $display("\n=== Todos los tests completados ===\n");
        $finish;
    end

    initial begin
        $dumpfile("mux_2_1_tb.vcd");
        $dumpvars(0, mux_2_1_tb);
    end

endmodule
