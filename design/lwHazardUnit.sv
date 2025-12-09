module lwHazardUnit  #(
    parameter WIDTH = 5
)(
    input logic [WIDTH-1:0] RegS1D,     // Source register 1 in Decode
    input logic [WIDTH-1:0] RegS2D,     // Source register 2 in Decode
    input logic [WIDTH-1:0] WriteRegE,  // Write register in Memory stage
    input logic MeMtoRegE,              // MeMtoReg signal
    input logic rst,                    // Reset signal
    output logic lwstall               // lwstall

);

    // Señales de comparación individuales
    logic f1, f2, a1, a2;


    comparador #(.WIDTH(WIDTH)) compR2RDE (
        .rst(rst),
        .a(RegS2D),
        .b(WriteRegE),
        .y(f1)
    );

        comparador #(.WIDTH(WIDTH)) compR1RDE (
        .rst(rst),
        .a(RegS1D),
        .b(WriteRegE),
        .y(f2)
    );

    assign a1 = f1 & MeMtoRegE;
    assign a2 = f2 & MeMtoRegE;
    assign lwstall = a1 | a2;

endmodule