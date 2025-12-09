module DataMemory_tb();
    
    //=================================================================
    // CONFIGURACIÓN DEL TESTBENCH
    //=================================================================
    
    // Parámetros del módulo de memoria
    parameter WIDTH = 32;        // Ancho de datos en bits (32 bits = 4 bytes)
    parameter DEPTH = 12;        // Bits de dirección (2^12 = 4096 direcciones)
    parameter CLK_PERIOD = 10;   // Período del reloj en unidades de tiempo
    
    //=================================================================
    // DECLARACIÓN DE SEÑALES
    //=================================================================
    
    // Señales de control del sistema
    logic clk;              // Reloj del sistema
    logic rst;              // Reset (reinicio del sistema)
    
    // Señales de control de memoria
    logic MemWrite;         // Habilita escritura en memoria (1 = escribir)
    logic MemRead;          // Habilita lectura de memoria (1 = leer)
    
    // Señales de selección de tamaño de datos
    logic one_byte;         // Selecciona operación de 1 byte
    logic two_byte;         // Selecciona operación de 2 bytes (halfword)
    logic four_bytes;       // Selecciona operación de 4 bytes (word completa)
    logic unsigned_load;    // 1 = carga sin signo, 0 = carga con signo
    
    // Señales de datos y direcciones
    logic [DEPTH-1:0] Address;    // Dirección de memoria (12 bits)
    logic [WIDTH-1:0] WriteData;  // Datos a escribir (32 bits)
    logic [WIDTH-1:0] ReadData;   // Datos leídos de memoria (32 bits)
    
    //=================================================================
    // INSTANCIACIÓN DEL MÓDULO BAJO PRUEBA (DUT)
    //=================================================================
    
    // Conecta todas las señales automáticamente usando .*
    DataMemory #(WIDTH, DEPTH) dut (.*);
    
    //=================================================================
    // GENERACIÓN DEL RELOJ
    //=================================================================
    
    // Inicializa el reloj en 0
    initial clk = 0;
    
    // Cambia el reloj cada medio período (genera onda cuadrada)
    always #(CLK_PERIOD/2) clk = ~clk;
    
    //=================================================================
    // TAREAS AUXILIARES PARA SIMPLIFICAR LAS PRUEBAS
    //=================================================================
    
    // TAREA DE RESET: Reinicia el sistema
    task reset(); 
    begin 
        $display("🔄 Ejecutando reset del sistema...");
        rst = 1;           // Activa reset
        @(posedge clk);    // Espera un ciclo de reloj
        rst = 0;           // Desactiva reset
        $display("✅ Reset completado");
    end 
    endtask
    
    // TAREA DE ESCRITURA: Escribe datos en memoria
    task write(input [DEPTH-1:0] addr,      // Dirección donde escribir
               input [WIDTH-1:0] data,      // Datos a escribir
               input [2:0] size);           // Tamaño: 1=byte, 2=halfword, 4=word
    begin
        @(posedge clk);  // Sincroniza con el reloj
        
        // Configura la operación de escritura
        Address = addr;
        WriteData = data;
        MemWrite = 1'b1;    // Habilita escritura
        MemRead = 1'b0;     // Deshabilita lectura
        
        // Selecciona el tamaño de datos según el parámetro 'size'
        case(size)
            1: {one_byte, two_byte, four_bytes, unsigned_load} = 4'b1000;  // 1 byte
            2: {one_byte, two_byte, four_bytes, unsigned_load} = 4'b0100;  // 2 bytes
            4: {one_byte, two_byte, four_bytes, unsigned_load} = 4'b0010;  // 4 bytes
            default: {one_byte, two_byte, four_bytes, unsigned_load} = 4'b0010;
        endcase
        
        @(posedge clk);     // Espera un ciclo para completar escritura
        MemWrite = 0;       // Deshabilita escritura
        
        $display("📝 Escribiendo: Addr=0x%03X, Data=0x%08X, Size=%0d bytes", 
                 addr, data, size);
    end 
    endtask
    
    // TAREA DE LECTURA: Lee datos de memoria
    task read(input [DEPTH-1:0] addr,       // Dirección a leer
              input [2:0] size,             // Tamaño: 1=byte, 2=halfword, 4=word
              input unsign = 0);            // 0=con signo, 1=sin signo
    begin
        @(posedge clk);  // Sincroniza con el reloj
        
        // Configura la operación de lectura
        Address = addr;
        MemWrite = 1'b0;    // Deshabilita escritura
        MemRead = 1'b1;     // Habilita lectura
        
        // Selecciona el tamaño y tipo de carga
        case(size)
            1: {one_byte, two_byte, four_bytes, unsigned_load} = {3'b100, unsign};
            2: {one_byte, two_byte, four_bytes, unsigned_load} = {3'b010, unsign};
            4: {one_byte, two_byte, four_bytes, unsigned_load} = 4'b0010;
            default: {one_byte, two_byte, four_bytes, unsigned_load} = 4'b0010;
        endcase
        
        @(posedge clk);     // Espera un ciclo para completar lectura
        
        $display(" Leyendo: Addr=0x%03X, Size=%0d bytes, %s → Data=0x%08X", 
                 addr, size, unsign ? "unsigned" : "signed", ReadData);
    end 
    endtask
    
    // TAREA DE VERIFICACIÓN: Compara el resultado con lo esperado
    task check(input [WIDTH-1:0] expected,  // Valor esperado
               input string test_name);     // Nombre de la prueba
    begin
        if (ReadData !== expected) begin
            $display(" FALLO en %s:", test_name);
            $display("   Esperado: 0x%08X", expected);
            $display("   Obtenido: 0x%08X", ReadData);
            $error("Test fallido: %s", test_name);
        end else begin
            $display(" ÉXITO en %s: 0x%08X", test_name, ReadData);
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
        
        // Inicialización del sistema
        reset();
        
        $display("\n PRUEBA 1: Escritura y lectura de palabras completas (32 bits)");
        write(0, 32'hDEADBEEF, 4);     // Escribe palabra completa en dirección 0
        read(0, 4);                     // Lee palabra completa
        check(32'hDEADBEEF, "Escritura/Lectura de palabra");
        
        $display("\nPRUEBA 2: Manejo de bytes con y sin signo");
        write(4, 32'h000000FF, 1);     // Escribe byte 0xFF (255 decimal)
        
        // Lee como byte con signo (0xFF se extiende a 0xFFFFFFFF = -1)
        read(4, 1, 0);                  
        check(32'hFFFFFFFF, "Byte con signo (extensión de signo)");
        
        // Lee como byte sin signo (0xFF se extiende a 0x000000FF = 255)
        read(4, 1, 1);                  
        check(32'h000000FF, "Byte sin signo (extensión con ceros)");
        
        $display("\n PRUEBA 3: Manejo de halfwords (16 bits) con y sin signo");
        write(8, 32'h0000FFFF, 2);     // Escribe halfword 0xFFFF
        
        // Lee como halfword con signo (0xFFFF = -1 en complemento a 2)
        read(8, 2, 0);                  
        check(32'hFFFFFFFF, "Halfword con signo");
        
        // Lee como halfword sin signo (0xFFFF = 65535 decimal)
        read(8, 2, 1);                  
        check(32'h0000FFFF, "Halfword sin signo");
        
        $display("\n PRUEBA 4: Verificación del formato little-endian");
        // En little-endian, el byte menos significativo se almacena primero
        write(12, 32'h12345678, 4);    // Escribe 0x12345678
        
        // En memoria se almacena como: [12][34][56][78] → [78][56][34][12]
        read(12, 1, 1);                // Lee primer byte (menos significativo)
        check(32'h00000078, "Little-endian: Byte 0 (LSB)");
        
        read(13, 1, 1);                // Lee segundo byte
        check(32'h00000056, "Little-endian: Byte 1");
        
        read(12, 2, 1);                // Lee halfword (2 bytes)
        check(32'h00005678, "Little-endian: Halfword");
        
        $display("\n PRUEBA 5: Pruebas en los límites de memoria");
        write(4092, 32'hAAAABBBB, 4); // Escribe cerca del final de memoria
        read(4092, 4);
        check(32'hAAAABBBB, "Escritura en límite de memoria");
        
        write(4095, 32'hCCCCDDDD, 1); // Escribe en la última dirección
        read(4095, 1, 1);
        check(32'h000000DD, "Último byte de memoria");
        
        $display("\n PRUEBA 6: Comportamiento durante reset");
        rst = 1;                       // Activa reset
        read(0, 4);                    // Intenta leer durante reset
        check(32'h00000000, "Lectura durante reset");
        rst = 0;                       // Desactiva reset
        
        $display("\n PRUEBA 7: Manejo de direcciones inválidas");
        read(4096, 4);                 // Dirección fuera del rango válido
        check(32'h00000000, "Dirección inválida");
        
        $display("\n" + "="*50);
        $display(" TODAS LAS PRUEBAS COMPLETADAS");
        $display("="*50 + "\n");
        
        $finish;  // Termina la simulación
    end
    
    //=================================================================
    // MONITOR PARA DEPURACIÓN (OPCIONAL)
    //=================================================================
    
    // Muestra el estado de las señales en cada cambio
    initial begin
        $display("\n Monitor de señales activado:");
        $monitor("Tiempo:%0t | Addr:0x%03X | WriteData:0x%08X | ReadData:0x%08X | Write:%b | Read:%b | Tamaño:%b%b%b | Unsigned:%b", 
                 $time, Address, WriteData, ReadData, MemWrite, MemRead, 
                 one_byte, two_byte, four_bytes, unsigned_load);
    end

    //=================================================================
    // GENERACIÓN DE ARCHIVOS DE ONDAS PARA VISUALIZACIÓN
    //=================================================================
    
    // Guarda todas las señales en un archivo VCD para ver las formas de onda
    initial begin
        $dumpfile("DataMemory_tb.vcd");
        $dumpvars(0, DataMemory_tb);
    end 
    
endmodule