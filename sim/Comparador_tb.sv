// Testbench  para el módulo RegisterFile
`timescale 1ns/1ps
module comparador_tb #(parameter WIDTH=5);
  // Señales del testbench
  //Señales de entrada y salida
 logic [WIDTH-1:0] a;
 logic [WIDTH-1:0] b;
 logic rst;
 logic y;
  // Instanciación del DUT (Device Under Test)
  comparador #(
    .WIDTH(WIDTH) 
  ) dut_comp (
    .rst(rst),
    .a(a),
    .b(b),
    .y(y)

  );
  
  initial begin
     #10;
     rst=1;
     a=5'b00000;
     b=5'b00000;
     #10;
    rst=0;
    #10;
     a=5'b10101;
     b=5'b10101;
    #10;
     a=5'b10001;
     b=5'b10101;
        #10;
     $finish;
  end

  // Inicio de la simulación
  initial begin
    // Configurar volcado de ondas (opcional)
    $dumpfile("comparador_tb.vcd");
    $dumpvars(0, comparador_tb);
  end
  
endmodule