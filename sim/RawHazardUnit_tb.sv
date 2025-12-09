// Testbench  para el módulo RegisterFile
`timescale 1ns/1ps
module RawHazardUnit_tb #(parameter WIDTH=5);
  // Señales del testbench
  //Señales de entrada y salida
     logic [WIDTH-1:0] RegS1E;
     logic [WIDTH-1:0] RegS2E;
     logic [WIDTH-1:0] WriteRegM;
     logic [WIDTH-1:0] WriteRegWB;
     logic RegWWB;
     logic RegWM;
     logic rst;
     logic [1:0] src1;
     logic [1:0] src2;
  // Instanciación del DUT (Device Under Test)
  RawHazardUnit #(
    .WIDTH(WIDTH) 
  ) dut_rawhazardunit (
      .RegS1E(RegS1E),
      .RegS2E(RegS2E),
      .WriteRegM(WriteRegM),
      .WriteRegWB(WriteRegWB),
      .RegWWB(RegWWB),
      .RegWM(RegWM),
      .rst(rst),
      .src1(src1),
      .src2(src2)
  );
  
  initial begin
     rst=1;
     RegS2E=5'b00000;
     RegS1E=5'b00000;
     WriteRegM=5'b00000;
     WriteRegWB=5'b00000;
     RegWWB=0;
     RegWM=0;
     //Hazard Raw en una instruccion en la parte de memoria para el registro 1
     #10;
     rst=0;
     RegS2E=5'b00001;
     RegS1E=5'b01001;
     WriteRegM=5'b01001;
     WriteRegWB=5'b00000;
     RegWWB=0;
     RegWM=1;
    //Hazard Raw en una instruccion en la parte de memoria para el registro 2
    #10;
     RegS2E=5'b01001;
     RegS1E=5'b00000;
     WriteRegM=5'b01001;
     WriteRegWB=5'b00000;
     RegWWB=0;
     RegWM=1;
     //Hazard Raw en una instruccion en la parte de WB para el registro 1
    #10;
     RegS2E=5'b00000;
     RegS1E=5'b01001;
     WriteRegM=5'b00000;
     WriteRegWB=5'b01001;
     RegWWB=1;
     RegWM=0;
      //Hazard Raw en una instruccion en la parte de WB para el registro 2
        #10;
     RegS2E=5'b01001;
     RegS1E=5'b00000;
     WriteRegM=5'b00000;
     WriteRegWB=5'b01001;
     RegWWB=1;
     RegWM=0;
     //sin Hazard Raw
             #10;
     RegS2E=5'b01001;
     RegS1E=5'b00000;
     WriteRegM=5'b00000;
     WriteRegWB=5'b01001;
     RegWWB=0;
     RegWM=0;

     #10;
     RegS2E=5'b01001;
     RegS1E=5'b00100;
     WriteRegM=5'b00010;
     WriteRegWB=5'b01011;
     RegWWB=1;
     RegWM=1;
    //Salida deberia ser 01 (Prioridad a memory)
    #10;
     RegS2E=5'b01001;
     RegS1E=5'b00001;
     WriteRegM=5'b00001;
     WriteRegWB=5'b01001;
     RegWWB=1;
     RegWM=1;

     #10;
     $finish;
  end

  // Inicio de la simulación
  initial begin
    // Configurar volcado de ondas (opcional)
    $dumpfile("RawHazardUnit_tb.vcd");
    $dumpvars(0, RawHazardUnit_tb);
  end
  
endmodule