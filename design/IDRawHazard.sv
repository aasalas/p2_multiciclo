module IDRawHazard #(
    parameter WIDTH = 5
)(
    input  logic [WIDTH-1:0] WriteRegWB, Rs1ID, Rs2ID,
    input  logic RegWriteW, rst,
    output logic IDHazardStall
);

    logic compRs1, compRs2, coincidence;

    comparador #(.WIDTH(WIDTH)) compR1ID (
        .rst(rst),
        .a(Rs1ID),
        .b(WriteRegWB),
        .y(compRs1)
    );

    comparador #(.WIDTH(WIDTH)) compR2ID (
        .rst(rst),
        .a(Rs2ID),
        .b(WriteRegWB),
        .y(compRs2)
    );

    assign coincidence = compRs2 | compRs1;
    assign IDHazardStall = coincidence & RegWriteW;

endmodule
