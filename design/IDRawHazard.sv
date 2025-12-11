module IDRawHazard #(
    parameter WIDTH = 5
)(
    input  logic [WIDTH-1:0] WriteRegWB, Rs1ID, Rs2ID,
    input  logic RegWriteW, rst,
    output logic IDHazardStall
);
    assign coincidencia = (Rs1ID == WriteRegWB) | (Rs2ID == WriteRegWB);
    // Detecta hazard: si hay escritura en WB y alguno de los registros coincide
    assign IDHazardStall = RegWriteW & coincidencia;

endmodule