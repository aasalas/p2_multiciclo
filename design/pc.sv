// ==============================================================================
// Program Counter (PC) Module
// ==============================================================================
// Mantiene y actualiza el program counter en cada ciclo de reloj
// PC comienza en 0 y se incrementa en 4 (tamaño de una instrucción en bytes)
// ==============================================================================

module pc(
    input  logic       clk,
    output logic [31:0] pc_out
);

    logic [31:0] pc = 32'h0;  // Inicializar PC en 0

    // Actualizar el PC en cada ciclo de reloj
    always_ff @(posedge clk) begin
        pc <= pc + 32'd4;  // Incrementa en 4 directamente
    end
    
    // Salida del PC actual
    assign pc_out = pc;

endmodule
