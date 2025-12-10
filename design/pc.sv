
// Program counter secuencial con soporte de stall. Reset fijo a 0.
module PC #(
    parameter int WIDTH = 32
)(
    input  logic             clk,
    input  logic             rst,
    input  logic             StallF,
    input  logic [WIDTH-1:0] PC_in,
    output logic [WIDTH-1:0] PC_out
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)          PC_out <= '0;   // reset lleva el PC a 0
        else if (!StallF) PC_out <= PC_in; // avanza solo si no hay stall
    end

endmodule