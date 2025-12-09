// Testbench  para el módulo RegisterFile
`timescale 1ns/1ps
module RegisterFile_tb #(parameter WIDTH=32, parameter ADDR_WIDTH=5) ();
  


  
  // Señales del testbench
  reg clk;
  reg rst;
  reg RegWrite;
  reg [ADDR_WIDTH-1:0] Rs1, Rs2, Rd;
  reg [WIDTH-1:0] WriteData;
  wire [WIDTH-1:0] ReadData1, ReadData2;
  
  // Variables para verificación
  integer error;
  integer finish_flag;
  integer i;
  
  // Modelo de referencia del banco de registros para verificación
  reg [WIDTH-1:0] reg_file_checker [0:31];
  
  // Instanciación del DUT (Device Under Test)
  RegisterFile #(
    .WIDTH(WIDTH), 
    .ADDR_WIDTH(ADDR_WIDTH)
  ) dut_reg_file (
    .clk(clk),
    .rst(rst),
    .RegWrite(RegWrite),
    .Rs1(Rs1),
    .Rs2(Rs2),
    .Rd(Rd),
    .WriteData(WriteData),
    .ReadData1(ReadData1),
    .ReadData2(ReadData2)
  );
  
  // Generación del reloj
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // Período de 10ns
  end
  
  // Inicialización
  initial begin
    // Inicializar señales
    WriteData = 0;
    Rd = 0;
    RegWrite = 0;
    Rs1 = 0;
    Rs2 = 0;
    error = 0;
    finish_flag = 0;
    
    // Inicializar modelo de referencia
    for (i = 0; i < 32; i = i + 1) begin
      reg_file_checker[i] = 0;
    end
    
    
    // Ejecutar las pruebas
    test_sequence();
  end
  
  // Secuencia principal de pruebas
  task test_sequence;
    begin
      $display("=== Iniciando pruebas del RegisterFile ===");
      
      // Reset inicial
      rst = 1;
      repeat(3) @(posedge clk);
      rst = 0;
      @(posedge clk);
      
      // Fase 1: Escribir valores en todos los registros
      $display("Fase 1: Escribiendo en registros 0-31");
      test_write_all_registers();
      
      // Fase 2: Leer registros
      $display("Fase 2: Leyendo registros");
      test_read_registers();
      
      // Fase 3: Prueba del registro x0
      $display("Fase 3: Probando registro x0 (debe ser siempre 0)");
      test_register_zero();
      
      // Fase 4: Prueba de reset
      $display("Fase 4: Probando reset");
      test_reset();
      
      // Finalizar
      repeat(10) @(posedge clk);
      
      if (error == 0) begin
        $display("*** TODAS LAS PRUEBAS PASARON EXITOSAMENTE ***");
      end else begin
        $display("*** SE ENCONTRARON %d ERRORES EN LAS PRUEBAS ***", error);
      end
      
      finish_flag = 1;
      $finish;
    end
  endtask
  
  // Task para escribir en todos los registros
  task test_write_all_registers;
    begin
      for (i = 0; i < 32; i = i + 1) begin
        @(negedge clk);
        WriteData = i * 4 + 100;
        Rd = i;
        RegWrite = 1;
        
        // Actualizar modelo de referencia
        if (i != 0) begin
          reg_file_checker[i] = WriteData;
        end
        
        @(posedge clk);
        #1; // Pequeño delay
      end
      
      RegWrite = 0; // Deshabilitar escritura
    end
  endtask
  
  // Task para leer registros
  task test_read_registers;
    begin
      // Leer registros de manera secuencial
      for (i = 0; i < 31; i = i + 1) begin
        @(negedge clk);
        Rs1 = i;
        Rs2 = i + 1;
        @(posedge clk);
        #1; // Esperar estabilización
        
        // Verificar ReadData1
        if (i == 0) begin
          if (ReadData1 !== 32'h0) begin
            $display("[ERROR] ReadData1 debería ser 0 cuando Rs1=0, pero es %h", ReadData1);
            error = error + 1;
          end
        end else begin
          if (ReadData1 !== reg_file_checker[i]) begin
            $display("[ERROR] ReadData1 mismatch: Rs1=%d, Expected=%h, Got=%h", 
                    i, reg_file_checker[i], ReadData1);
            error = error + 1;
          end
        end
        
        // Verificar ReadData2
        if ((i + 1) < 32) begin
          if ((i + 1) == 0) begin
            if (ReadData2 !== 32'h0) begin
              $display("[ERROR] ReadData2 debería ser 0 cuando Rs2=0, pero es %h", ReadData2);
              error = error + 1;
            end
          end else begin
            if (ReadData2 !== reg_file_checker[i + 1]) begin
              $display("[ERROR] ReadData2 mismatch: Rs2=%d, Expected=%h, Got=%h", 
                      i + 1, reg_file_checker[i + 1], ReadData2);
              error = error + 1;
            end
          end
        end
      end
    end
  endtask
  
  // Task para probar el registro x0
  task test_register_zero;
    begin
      // Intentar escribir en el registro x0
      @(negedge clk);
      WriteData = 32'hDEADBEEF;
      Rd = 0;
      RegWrite = 1;
      @(posedge clk);
      
      // Leer el registro x0
      @(negedge clk);
      RegWrite = 0;
      Rs1 = 0;
      Rs2 = 0;
      @(posedge clk);
      #1;
      
      // Verificar que sigue siendo 0
      if (ReadData1 !== 32'h0) begin
        $display("[ERROR] Registro x0 no es 0 después de intento de escritura: %h", ReadData1);
        error = error + 1;
      end
      
      if (ReadData2 !== 32'h0) begin
        $display("[ERROR] Registro x0 no es 0 en ReadData2: %h", ReadData2);
        error = error + 1;
      end
    end
  endtask
  
  // Task para probar el reset
  task test_reset;
    begin
      // Aplicar reset
      @(negedge clk);
      rst = 1;
      repeat(3) @(posedge clk);
      rst = 0;
      
      // Actualizar modelo de referencia
      for (i = 0; i < 32; i = i + 1) begin
        reg_file_checker[i] = 0;
      end
      
      // Verificar que todos los registros estén en 0
      for (i = 0; i < 32; i = i + 1) begin
        @(negedge clk);
        Rs1 = i;
        Rs2 = (i + 1) % 32;
        @(posedge clk);
        #1;
        
        if (ReadData1 !== 32'h0) begin
          $display("[ERROR] Registro %d no es 0 después del reset: %h", i, ReadData1);
          error = error + 1;
        end
      end
    end
  endtask
  
  // Monitor para verificación continua
  always @(posedge clk) begin
    if (!rst && RegWrite && (Rd != 5'b00000)) begin
      #1; // Pequeño delay para sincronización
      reg_file_checker[Rd] = WriteData;
    end
  end
  
  // Timeout de seguridad
  initial begin
    #100000; // 100us timeout
    if (!finish_flag) begin
      $display("[ERROR] Timeout - La simulación no terminó correctamente");
      $finish;
    end
  end
  
  // Inicio de la simulación
  initial begin
    // Configurar volcado de ondas (opcional)
    $dumpfile("RegisterFile_tb.vcd");
    $dumpvars(0, RegisterFile_tb);
    

  end
  
endmodule