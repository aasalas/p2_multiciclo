module Comparadores_mux (
    input  logic [31:0] RD1,    // Primer operando (típicamente rs1)
    input  logic [31:0] RD2,    // Segundo operando (típicamente rs2)
    output logic        S0      // Resultado de comparación
);

    // Comparaciones básicas
    logic igual;
    logic menor;
    logic mayor;
    
    assign igual = (RD1 == RD2);
    assign menor = (RD1 < RD2);   // Comparación con signo por defecto
    assign mayor = (RD1 > RD2);
    
    
    always_comb begin
        if (igual)
            S0 = 1'b1;
        else if (menor)
            S0 = 1'b1;
        else if (mayor)
            S0 = 1'b1;
        else
            S0 = 1'b0;  // Caso imposible, pero incluido para síntesis completa
    end
    
    // Advertencia si S0 siempre es 1 (lo cual es el caso actual)
    logic s0_always_high;
    assign s0_always_high = igual | menor | mayor;  // Siempre 1
    
    // synthesis translate_on

endmodule