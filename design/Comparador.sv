// Comparador combinacional 
module comparador #(parameter WIDTH=5) (
    // Señales de entrada y salida
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    input logic rst,
    output logic y
);  
    logic c0, c1, c2;
    
    assign c0 = rst ? 1'b0 : (~(a[0] ^ b[0]) & ~(a[1] ^ b[1]));
    assign c1 = rst ? 1'b0 : (c0 & ~(a[2] ^ b[2]));
    assign c2 = rst ? 1'b0 : (c1 & ~(a[3] ^ b[3]));
    assign y  = rst ? 1'b0 : (c2 & ~(a[4] ^ b[4]));

endmodule


