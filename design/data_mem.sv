

module data_mem(
    input logic clk,
    input logic memread,
    input logic memwrite,
    input logic [31:0] addr,
    input logic [31:0] wdata,
    output logic [31:0] rdata
    );
    logic [31:0] mem [0:255];
    always_ff @(posedge clk) begin
        if (memwrite) mem[addr[9:2]] <= wdata; // lw (load word)
        if (memread) rdata <= mem[addr[9:2]]; // sw (store word)
    end
endmodule