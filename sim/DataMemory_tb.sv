module DataMemory_tb();
    
    //=================================================================
    // CONFIGURACION DEL TESTBENCH
    //=================================================================
    
    // Parametros del modulo de memoria
    parameter WIDTH = 32;        // Ancho de datos en bits (32 bits = 4 bytes)
    parameter DEPTH = 12;        // Bits de direccion (2^12 = 4096 direcciones)
    parameter CLK_PERIOD = 10;   // Periodo del reloj en unidades de tiempo
    
    //=================================================================
    // DECLARACION DE SENALES
    //=================================================================
    
    logic clk;              // Reloj del sistema
    logic rst;              // Reset (reinicio del sistema)
    
    logic MemWrite;         // Habilita escritura en memoria (1 = escribir)
    logic MemRead;          // Habilita lectura de memoria (1 = leer)
    
    logic one_byte;         // Selecciona operacion de 1 byte
    logic two_byte;         // Selecciona operacion de 2 bytes (halfword)
    logic four_bytes;       // Selecciona operacion de 4 bytes (word completa)
    logic unsigned_load;    // 1 = carga sin signo, 0 = carga con signo
    
    logic [DEPTH-1:0] Address;    // Direccion de memoria (12 bits)
    logic [WIDTH-1:0] WriteData;  // Datos a escribir (32 bits)
    logic [WIDTH-1:0] ReadData;   // Datos leidos de memoria (32 bits)
    
    //=================================================================
    // INSTANCIACION DEL MODULO BAJO PRUEBA (DUT)
    //=================================================================
    
    DataMemory #(WIDTH, DEPTH) dut (.*);
    
    //=================================================================
    // GENERACION DEL RELOJ
    //=================================================================
    
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;
    
    //=================================================================
    // TAREAS AUXILIARES PARA SIMPLIFICAR LAS PRUEBAS
    //=================================================================
    
    // TAREA DE RESET: Reinicia el sistema
    task reset(); 
    begin 
        $display("Ejecutando reset del sistema...");
        rst = 1;
        @(posedge clk);
        rst = 0;
        $display("Reset completado");
    end 
    endtask
    
    // TAREA DE ESCRITURA: Escribe datos en memoria
    task write(input [DEPTH-1:0] addr,
               input [WIDTH-1:0] data,
               input [2:0] size);
    begin
        @(posedge clk);
        Address = addr;
        WriteData = data;
        MemWrite = 1'b1;
        MemRead = 1'b0;
        case(size)
            1: {one_byte, two_byte, four_bytes, unsigned_load} = 4'b1000;
            2: {one_byte, two_byte, four_bytes, unsigned_load} = 4'b0100;
            4: {one_byte, two_byte, four_bytes, unsigned_load} = 4'b0010;
            default: {one_byte, two_byte, four_bytes, unsigned_load} = 4'b0010;
        endcase
        @(posedge clk);
        MemWrite = 0;
        $display("Escribiendo: Addr=0x%03X, Data=0x%08X, Size=%0d bytes", addr, data, size);
    end 
    endtask
    
    // TAREA DE LECTURA: Lee datos de memoria
    task read(input [DEPTH-1:0] addr,
              input [2:0] size,
              input unsign = 0);
    begin
        @(posedge clk);
        Address = addr;
        MemWrite = 1'b0;
        MemRead = 1'b1;
        case(size)
            1: {one_byte, two_byte, four_bytes, unsigned_load} = {3'b100, unsign};
            2: {one_byte, two_byte, four_bytes, unsigned_load} = {3'b010, unsign};
            4: {one_byte, two_byte, four_bytes, unsigned_load} = 4'b0010;
            default: {one_byte, two_byte, four_bytes, unsigned_load} = 4'b0010;
        endcase
        @(posedge clk);
        $display(" Leyendo: Addr=0x%03X, Size=%0d bytes, %s -> Data=0x%08X", addr, size, unsign ? "unsigned" : "signed", ReadData);
    end 
    endtask
    
    // TAREA DE VERIFICACION: Compara el resultado con lo esperado
    task check(input [WIDTH-1:0] expected,
               input string test_name);
    begin
        if (ReadData !== expected) begin
            $display(" FALLO en %s:", test_name);
            $display("   Esperado: 0x%08X", expected);
            $display("   Obtenido: 0x%08X", ReadData);
            $error("Test fallido: %s", test_name);
        end else begin
            $display(" EXITO en %s: 0x%08X", test_name, ReadData);
        end
    end 
    endtask
    
    //=================================================================
    // SECUENCIA PRINCIPAL DE PRUEBAS
    //=================================================================
    
    initial begin
        $display("\n" + "="*50);
        $display(" INICIANDO TESTBENCH DE MEMORIA DE DATOS");
        $display("="*50);
        
        reset();
        
        $display("\n PRUEBA 1: Escritura y lectura de palabras completas (32 bits)");
        write(0, 32'hDEADBEEF, 4);
        read(0, 4);
        check(32'hDEADBEEF, "Escritura/Lectura de palabra");
        
        $display("\nPRUEBA 2: Manejo de bytes con y sin signo");
        write(4, 32'h000000FF, 1);
        read(4, 1, 0);
        check(32'hFFFFFFFF, "Byte con signo (extension de signo)");
        read(4, 1, 1);
        check(32'h000000FF, "Byte sin signo (extension con ceros)");
        
        $display("\n PRUEBA 3: Manejo de halfwords (16 bits) con y sin signo");
        write(8, 32'h0000FFFF, 2);
        read(8, 2, 0);
        check(32'hFFFFFFFF, "Halfword con signo");
        read(8, 2, 1);
        check(32'h0000FFFF, "Halfword sin signo");
        
        $display("\n PRUEBA 4: Verificacion del formato little-endian");
        write(12, 32'h12345678, 4);
        read(12, 1, 1);
        check(32'h00000078, "Little-endian: Byte 0 (LSB)");
        read(13, 1, 1);
        check(32'h00000056, "Little-endian: Byte 1");
        read(12, 2, 1);
        check(32'h00005678, "Little-endian: Halfword");
        
        $display("\n PRUEBA 5: Pruebas en los limites de memoria");
        write(4092, 32'hAAAABBBB, 4);
        read(4092, 4);
        check(32'hAAAABBBB, "Escritura en limite de memoria");
        write(4095, 32'hCCCCDDDD, 1);
        read(4095, 1, 1);
        check(32'h000000DD, "Ultimo byte de memoria");
        
        $display("\n PRUEBA 6: Comportamiento durante reset");
        rst = 1;
        read(0, 4);
        check(32'h00000000, "Lectura durante reset");
        rst = 0;
        
        $display("\n PRUEBA 7: Manejo de direcciones invalidas");
        read(4096, 4);
        check(32'h00000000, "Direccion invalida");
        
        $display("\n" + "="*50);
        $display(" TODAS LAS PRUEBAS COMPLETADAS");
        $display("="*50 + "\n");
        
        $finish;
    end
    
    //=================================================================
    // MONITOR PARA DEPURACION (OPCIONAL)
    //=================================================================
    
    initial begin
        $display("\n Monitor de senales activado:");
        $monitor("Tiempo:%0t | Addr:0x%03X | WriteData:0x%08X | ReadData:0x%08X | Write:%b | Read:%b | Tamano:%b%b%b | Unsigned:%b", 
                 $time, Address, WriteData, ReadData, MemWrite, MemRead, 
                 one_byte, two_byte, four_bytes, unsigned_load);
    end

    //=================================================================
    // GENERACION DE ARCHIVOS DE ONDAS PARA VISUALIZACION
    //=================================================================
    
    initial begin
        $dumpfile("DataMemory_tb.vcd");
        $dumpvars(0, DataMemory_tb);
    end 
    
endmodule