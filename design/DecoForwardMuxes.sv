module DecoForwardMuxes(
    input logic comp_S2_WB,
    input logic comp_S2_M,
    input logic comp_S1_WB,
    input logic comp_S1_M,
    input logic RegWWB,
    input logic RegWM,
    input logic rst,
    output logic [1:0] src1,
    output logic [1:0] src2
);

    // Señales intermedias
    logic src2_from_M, src2_from_WB;
    logic src1_from_M, src1_from_WB;
    logic not_RegWM, not_rst;

    assign not_RegWM = ~RegWM;
    assign not_rst   = ~rst;

    // src2 forwarding logic
    assign src2_from_M  = comp_S2_M  & RegWM  & not_rst;
    assign src2_from_WB = comp_S2_WB & RegWWB & ~src2_from_M & not_rst;

    // src1 forwarding logic
    assign src1_from_M  = comp_S1_M  & RegWM  & not_rst;
    assign src1_from_WB = comp_S1_WB & RegWWB & ~src1_from_M & not_rst;

    // Corrección: srcX[1] = MEM, srcX[0] = WB
    assign src2[1] = src2_from_M;
    assign src2[0] = src2_from_WB;

    assign src1[1] = src1_from_M;
    assign src1[0] = src1_from_WB;

endmodule
