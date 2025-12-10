// lwHazardUnit
// Detecta hazard load-use: si la instruccion en EX es un load (MeMtoRegE=1)
// y su destino WriteRegE coincide con RS1 o RS2 de la instruccion en Decode,
// se activa lwstall para congelar el pipeline y esperar al dato cargado.
// lw x5, 6(x10) -> load en EX
// RD = x5, RS1 = x10, RS2 = -, IMM = 6
// 
// add x8, x5, x2 -> uso de x5 en Decode
// RS1 = x5, RS2 = x2, RD = x8
//
// Si WriteRegE (x5) == RegS1D (x5) -> lwstall = 1
module lwHazardUnit #(
    parameter WIDTH = 5
)(
    input  logic [WIDTH-1:0] RegS1D,    // RS1 en etapa Decode
    input  logic [WIDTH-1:0] RegS2D,    // RS2 en etapa Decode
    input  logic [WIDTH-1:0] WriteRegE, // RD en etapa EX (load pendiente)
    input  logic             MeMtoRegE, // Señal de load (mem a reg) en EX
    input  logic             rst,
    output logic             lwstall
);

    // Hazard load-use: si la instrucción en EX es un load
    // y su RD coincide con RS1 o RS2 de la instrucción en Decode.
    always_comb begin
        if (rst) lwstall = 1'b0;
        else     lwstall = MeMtoRegE && ((RegS1D == WriteRegE) || (RegS2D == WriteRegE));
    end

endmodule