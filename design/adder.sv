// sumador  multiproposito componente combinacional
module adder #(parameter WIDTH=32) (
//Señales de entrada y salida

input logic [WIDTH-1:0] a,
input logic [WIDTH-1:0] b,
output logic [WIDTH-1:0] out
);
assign out= a + b;    //sumar las entradas               

endmodule