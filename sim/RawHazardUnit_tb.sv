// Testbench para el modulo RawHazardUnit
`timescale 1ns/1ps
module RawHazardUnit_tb #(parameter WIDTH=5);
  // Senales del testbench
  logic [WIDTH-1:0] RegS1E;
  logic [WIDTH-1:0] RegS2E;
  logic [WIDTH-1:0] WriteRegM;
  logic [WIDTH-1:0] WriteRegWB;
  logic RegWWB;
  logic RegWM;
  logic rst;
  logic [1:0] src1;
  logic [1:0] src2;
  
  // Contadores para verificacion
  int test_count = 0;
  int pass_count = 0;
  int fail_count = 0;
  
  // Instanciacion del DUT (Device Under Test)
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
  
  // Task para verificar resultados
  task check_output(
    input string test_name,
    input logic [1:0] expected_src1,
    input logic [1:0] expected_src2
  );
    test_count++;
    #1; // Pequeno delay para estabilizacion
    
    if (src1 === expected_src1 && src2 === expected_src2) begin
      $display("PASS: %s - src1=%b, src2=%b", test_name, src1, src2);
      pass_count++;
    end else begin
      $display("FAIL: %s", test_name);
      $display("  Expected: src1=%b, src2=%b", expected_src1, expected_src2);
      $display("  Got:      src1=%b, src2=%b", src1, src2);
      fail_count++;
    end
  endtask
  
  initial begin
    $display("=== Iniciando testbench RawHazardUnit ===");
    $display("");
    
    // Test 0: Reset
    rst=1;
    RegS2E=5'b00000;
    RegS1E=5'b00000;
    WriteRegM=5'b00000;
    WriteRegWB=5'b00000;
    RegWWB=0;
    RegWM=0;
    #10;
    check_output("Reset activo", 2'b00, 2'b00);
    
    // Test 1: Hazard RAW en memoria para registro 1 (src1 debe ser 10 = forward desde MEM)
    rst=0;
    RegS1E=5'b01001;     // RS1 en EX = x9
    RegS2E=5'b00001;     // RS2 en EX = x1
    WriteRegM=5'b01001;  // RD en MEM = x9 (match con RS1!)
    WriteRegWB=5'b00000;
    RegWM=1;             // Hay escritura en MEM
    RegWWB=0;
    #10;
    check_output("RAW hazard: Forward desde MEM a src1", 2'b10, 2'b00);
    
    // Test 2: Hazard RAW en memoria para registro 2 (src2 debe ser 10 = forward desde MEM)
    RegS1E=5'b00000;
    RegS2E=5'b01001;     // RS2 en EX = x9
    WriteRegM=5'b01001;  // RD en MEM = x9 (match con RS2!)
    WriteRegWB=5'b00000;
    RegWM=1;
    RegWWB=0;
    #10;
    check_output("RAW hazard: Forward desde MEM a src2", 2'b00, 2'b10);
    
    // Test 3: Hazard RAW en WB para registro 1 (src1 debe ser 01 = forward desde WB)
    RegS1E=5'b01001;     // RS1 en EX = x9
    RegS2E=5'b00000;
    WriteRegM=5'b00000;
    WriteRegWB=5'b01001; // RD en WB = x9 (match con RS1!)
    RegWM=0;
    RegWWB=1;            // Hay escritura en WB
    #10;
    check_output("RAW hazard: Forward desde WB a src1", 2'b01, 2'b00);
    
    // Test 4: Hazard RAW en WB para registro 2 (src2 debe ser 01 = forward desde WB)
    RegS1E=5'b00000;
    RegS2E=5'b01001;     // RS2 en EX = x9
    WriteRegM=5'b00000;
    WriteRegWB=5'b01001; // RD en WB = x9 (match con RS2!)
    RegWM=0;
    RegWWB=1;
    #10;
    check_output("RAW hazard: Forward desde WB a src2", 2'b00, 2'b01);
    
    // Test 5: Sin hazard (no hay match)
    RegS1E=5'b00000;
    RegS2E=5'b01001;
    WriteRegM=5'b00000;
    WriteRegWB=5'b01001;
    RegWM=0;             // No hay escritura
    RegWWB=0;            // No hay escritura
    #10;
    check_output("Sin hazard: No forwarding", 2'b00, 2'b00);
    
    // Test 6: Sin match de registros (diferentes registros)
    RegS1E=5'b00100;     // RS1 = x4
    RegS2E=5'b01001;     // RS2 = x9
    WriteRegM=5'b00010;  // RD en MEM = x2 (no match)
    WriteRegWB=5'b01011; // RD en WB = x11 (no match)
    RegWM=1;
    RegWWB=1;
    #10;
    check_output("Sin match de registros", 2'b00, 2'b00);
    
    // Test 7: Prioridad a memoria (MEM tiene prioridad sobre WB)
    RegS1E=5'b00001;     // RS1 = x1
    RegS2E=5'b01001;     // RS2 = x9
    WriteRegM=5'b00001;  // RD en MEM = x1 (match con RS1!)
    WriteRegWB=5'b01001; // RD en WB = x9 (match con RS2!)
    RegWM=1;             // Ambos tienen escritura
    RegWWB=1;
    #10;
    check_output("Prioridad: MEM sobre WB", 2'b10, 2'b10);
    
    // Test 8: Doble match - mismo registro en MEM y WB (MEM tiene prioridad)
    RegS1E=5'b00001;     // RS1 = x1
    RegS2E=5'b00001;     // RS2 = x1 (mismo registro)
    WriteRegM=5'b00001;  // RD en MEM = x1 (match!)
    WriteRegWB=5'b00001; // RD en WB = x1 (también match, pero MEM tiene prioridad)
    RegWM=1;
    RegWWB=1;
    #10;
    check_output("Doble match: MEM tiene prioridad", 2'b10, 2'b10);

    // Resumen final
    $display("");
    $display("=== RESUMEN DE PRUEBAS ===");
    $display("Total de pruebas: %0d", test_count);
    $display("Pruebas exitosas: %0d", pass_count);
    $display("Pruebas fallidas: %0d", fail_count);
    
    if (fail_count == 0) begin
      $display(" TODAS LAS PRUEBAS PASARON!");
    end else begin
      $display("  Algunas pruebas fallaron.");
    end
    
    $display("");
    #10;
    $finish;
  end

  // Sistema de guardado de los resultados del testbench
  initial begin
    $dumpfile("RawHazardUnit_tb.vcd");
    $dumpvars(0, RawHazardUnit_tb);
  end
  
endmodule