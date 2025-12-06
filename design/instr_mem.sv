module instr_mem(
    input logic clk, 
    input logic [31:0] addr, 
    output logic [31:0] instr
    );
    
    logic [31:0] mem [0:255];
    initial begin
    // small test program (assembled manually)
    // example: add x1,x0,x0 -> encoded as add x1,x0,x0
    // We'll load program from testbench using hierarchical access
        for (int i=0;i<256;i++) mem[i]=32'h00000013; // NOP = ADDI x0,x0,0
    end
    always_ff @(posedge clk) begin
        instr <= mem[addr[9:2]]; // word aligned
    end
endmodule