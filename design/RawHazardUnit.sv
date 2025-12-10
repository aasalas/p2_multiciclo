// Raw Hazard Unit - Implementación con solo compuertas lógicas
module RawHazardUnit #(
    parameter WIDTH = 5
)(
    input logic [WIDTH-1:0] RegS1E,     // Source register 1 in Execute
    input logic [WIDTH-1:0] RegS2E,     // Source register 2 in Execute
    input logic [WIDTH-1:0] WriteRegM,  // Write register in Memory stage
    input logic [WIDTH-1:0] WriteRegWB, // Write register in Writeback stage
    input logic RegWWB,                 // Write enable for Writeback stage
    input logic RegWM,                  // Write enable for Memory stage
    input logic rst,                    // Reset signal
    output logic [1:0] src1,            // Forward control for source 1
    output logic [1:0] src2             // Forward control for source 2
);

    // Señales de comparación individuales
    logic comp_S2_WB, comp_S2_M, comp_S1_WB, comp_S1_M;

    // Compare RegS2E con WriteRegWB
    comparador #(.WIDTH(WIDTH)) compR2WB (
        .rst(rst),
        .a(RegS2E),
        .b(WriteRegWB),
        .y(comp_S2_WB)
    );

    // Compare RegS2E con WriteRegM
    comparador #(.WIDTH(WIDTH)) compR2M (
        .rst(rst),
        .a(RegS2E),
        .b(WriteRegM),
        .y(comp_S2_M)
    );

    // Compare RegS1E con WriteRegWB
    comparador #(.WIDTH(WIDTH)) compR1WB (
        .rst(rst),
        .a(RegS1E),
        .b(WriteRegWB),
        .y(comp_S1_WB)
    );

    // Compare RegS1E con WriteRegM
    comparador #(.WIDTH(WIDTH)) compR1M (
        .rst(rst),
        .a(RegS1E),
        .b(WriteRegM),
        .y(comp_S1_M)
    );

    DecoForwardMuxes DecoForwardMuxes(
        .comp_S2_WB(comp_S2_WB),
        .comp_S2_M(comp_S2_M),
        .comp_S1_WB(comp_S1_WB),
        .comp_S1_M(comp_S1_M),
        .RegWWB(RegWWB),
        .RegWM(RegWM),
        .rst(rst),
        .src1(src1),
        .src2(src2)
    );

endmodule

