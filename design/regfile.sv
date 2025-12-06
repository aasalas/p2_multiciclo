

module regfile(
    input logic clk, 
    input logic we, 
    input logic [4:0] ra1, 
    input logic [4:0] ra2, 
    input logic [4:0] wa, 
    input logic [31:0] wd, 
    output logic [31:0] rd1, 
    output logic [31:0] rd2
    );
    
    logic [31:0] regs [0:31];
    initial begin
        for (int i=0;i<32;i++) regs[i]=0;
    end

    assign rd1 = (ra1==0)?32'd0:regs[ra1];
    assign rd2 = (ra2==0)?32'd0:regs[ra2];
    always_ff @(posedge clk) begin
        if (we && wa!=0) regs[wa] <= wd;
    end
endmodule

