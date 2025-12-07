`timescale 1ns/1ps

module IF_tb;

    // Parámetros
    localparam CLK_PERIOD = 37037;  // 27MHz = 1/27MHz ≈ 37.037ns
    
    // Señales de testbench
    logic clk;
    logic rst;
    
    // Instanciar TOP_IF
    TOP_IF dut(
        .clk(clk),
        .rst(rst)
    );
    
    // Generador de reloj a 27MHz
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Testbench principal
    initial begin
        $display("=== Testbench Instruction Fetch (IF) Stage ===");
        $display("Frecuencia: 27MHz, Período: %0.2f ns", CLK_PERIOD/1000.0);
        
        // Reset inicial
        rst = 1'b1;
        #(CLK_PERIOD * 2);
        rst = 1'b0;
        
        $display("\nInicio de simulación");
        
        // Simulación durante 10 ciclos de reloj
        repeat(10) begin
            @(posedge clk);
            $display("Ciclo: PC = %d", dut.pc_unit.pc);
        end
        
        $display("\n=== Simulación completada ===");
        $finish;
    end
    
    // Monitor de señales importantes
    initial begin
        $monitor("Tiempo: %0dns | CLK: %b | PC: %d | Instr: %h", 
                 $time, clk, dut.pc_unit.pc, dut.instr_if);
    end

endmodule
