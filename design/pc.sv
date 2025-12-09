//Program counter para el procesador, es un componente secuencial que dicata el orden del flujo de la ejecución de instrucciones
module PC #(parameter WIDTH=32) (
input clk,rst, //Señales de control
input logic [WIDTH-1:0] PC_in, // Entrada del PC
input logic StallF,
output logic [WIDTH-1:0] PC_out // salida del PC

);

always_ff @(posedge clk or posedge rst)
begin
    if(rst)
    PC_out <= 32'b0; // si se activa el rst, devolver el PC a 0
else if(~StallF) 
    PC_out <= PC_in; // sino, seguir operacion normal
end 


endmodule