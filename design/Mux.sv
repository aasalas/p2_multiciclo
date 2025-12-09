// Mux 2:1 genérico, combinacional
module Mux #(parameter WIDTH = 32) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             sel, // 1 -> b, 0 -> a
    output logic [WIDTH-1:0] out
);

    // Asignación continua: combina sin lógica secuencial
    assign out = sel ? b : a;

endmodule