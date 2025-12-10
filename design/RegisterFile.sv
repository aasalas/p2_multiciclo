// Banco de registros del procesador RISC-V
module RegisterFile #(
    parameter int WIDTH = 32,
    parameter int ADDR_WIDTH = 5
)(
    input  logic              clk, rst,
    input  logic              RegWrite,
    input  logic [ADDR_WIDTH-1:0] Rs1, Rs2, Rd,
    input  logic [WIDTH-1:0]  WriteData,
    output logic [WIDTH-1:0]  ReadData1, ReadData2
);

    logic [WIDTH-1:0] Registers [31:0];

    // Escritura sincrona
    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) 
                Registers[i] <= '0;
        end
        else if (RegWrite && Rd != '0) Registers[Rd] <= WriteData;
    end

    // Lectura combinacional
    always_comb begin
        ReadData1 = (Rs1 == '0) ? '0 : Registers[Rs1];
        ReadData2 = (Rs2 == '0) ? '0 : Registers[Rs2];
    end

endmodule