//Mux multipropósito para el procesador, es un componente combinacional 

module ForwardMux #(parameter WIDTH=32) (
// Señales de entrada y salida
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    input logic [WIDTH-1:0] c,
    input logic [1:0] sel, //bits de selcción de, va a decir cual de las 2 entradas pasa a la salida
    output logic [WIDTH-1:0] out

);

always_comb begin 

if(sel==00) out=a;  
else if (sel==01) out=b;        
else if (sel==10) out=c;
else
    out = 2'b0; 
end

endmodule