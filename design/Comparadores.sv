module Comparadores_mux (
    input logic [31:0] RD1,       
    input logic [31:0] RD2,             
    output logic S0
        
);

logic igual; 
logic menor; 
logic mayor; 
logic S0_sel; 
logic S1_sel; 

assign igual = (RD1 == RD2);     
assign mayor = (RD1 > RD2);      
assign menor = (RD1 < RD2);  

assign S0_sel = ~igual & menor;      
assign S1_sel = ~igual & mayor; 

always_comb begin
        if ({S1_sel,S0_sel} == 2'b00)
            S0 = igual;
        else if ({S1_sel,S0_sel} == 2'b01)
            S0 = menor;
        else if ({S1_sel,S0_sel} == 2'b10)
            S0 = mayor;
        else
            S0 = 1'b0;    
    end
    

endmodule