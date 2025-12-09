`timescale 1ns / 1ps

module lwHazardUnit_tb;
    
    parameter WIDTH = 5;
    
    // Señales del testbench
    logic [WIDTH-1:0] RegS1D, RegS2D, WriteRegE;
    logic MeMtoRegE, rst, lwstall;
    
    // Instanciación del DUT
    lwHazardUnit #(.WIDTH(WIDTH)) dut (.*);
    
    // Task para pruebas
    task test(input [WIDTH-1:0] s1, s2, wd, input mem_reg, reset, expected, input string name);
        {RegS1D, RegS2D, WriteRegE, MeMtoRegE, rst} = {s1, s2, wd, mem_reg, reset};
        #1;
        $display("%s: %s", name, (lwstall == expected) ? "PASS" : "FAIL");
    endtask
    
    initial begin
        $display("=== lwHazardUnit Testbench ===");
        
        // Reset tests
        test(5'd1, 5'd2, 5'd1, 1'b1, 1'b1, 1'b0, "Reset activo");
        
        // No-load tests (MeMtoRegE = 0)
        test(5'd1, 5'd2, 5'd1, 1'b0, 1'b0, 1'b0, "No-load con match S1");
        test(5'd1, 5'd2, 5'd2, 1'b0, 1'b0, 1'b0, "No-load con match S2");
        
        // Load hazards (MeMtoRegE = 1)
        test(5'd1, 5'd2, 5'd1, 1'b1, 1'b0, 1'b1, "Load hazard S1");
        test(5'd1, 5'd2, 5'd2, 1'b1, 1'b0, 1'b1, "Load hazard S2");
        test(5'd1, 5'd1, 5'd1, 1'b1, 1'b0, 1'b1, "Load hazard ambos");
        
        // No hazards
        test(5'd1, 5'd2, 5'd3, 1'b1, 1'b0, 1'b0, "Load sin hazard");
        test(5'd0, 5'd1, 5'd0, 1'b1, 1'b0, 1'b1, "Hazard registro 0");
        
        $display("=== Tests completados ===");
        $finish;
    end

      // Inicio de la simulación
  initial begin
    // Configurar volcado de ondas (opcional)
    $dumpfile("lwHazardUnit_tb.vcd");
    $dumpvars(0, lwHazardUnit_tb);
  end
    
endmodule