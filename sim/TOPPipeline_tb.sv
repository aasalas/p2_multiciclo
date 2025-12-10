// Testbench simplificado para el procesador RISC-V pipeline TOPPipeline
`timescale 1ns / 1ps

module TOPPipeline_tb;
    // Parametros del testbench
    parameter WIDTH = 32;
    parameter DEPTH_IMEM = 64;
    parameter DEPTH_DMEM = 12;
    parameter PERIOD = 10; // 10ns = 100MHz
    
    // Senales del testbench
    logic clk;
    logic rst;
    
    // Instanciacion del DUT (Device Under Test)
    TOPPipeline #(
        .WIDTH(WIDTH),
        .DEPTH_IMEM(DEPTH_IMEM),
        .DEPTH_DMEM(DEPTH_DMEM)
    ) dut (
        .clk(clk),
        .rst(rst)
    );
    
    // Generacion del reloj
    initial begin
        clk = 0;
        forever #(PERIOD/2) clk = ~clk;
    end
    
    // Variables para monitoreo simplificado
    logic [WIDTH-1:0] current_instruction;
    logic [6:0] opcode;
    logic [4:0] rd, rs1, rs2;
    logic [2:0] func3;
    logic [6:0] func7;
    
    // Asignaciones para monitoreo
    assign current_instruction = dut.instruction_ID;
    assign opcode = current_instruction[6:0];
    assign rd = current_instruction[11:7];
    assign func3 = current_instruction[14:12];
    assign rs1 = current_instruction[19:15];
    assign rs2 = current_instruction[24:20];
    assign func7 = current_instruction[31:25];
    
    // Funcion para decodificar el nombre de la instruccion
    function string get_instruction_name(logic [6:0] op, logic [2:0] f3, logic [6:0] f7);
        case (op)
            7'b0110011: begin // R-type
                case (f3)
                    3'b000: return (f7 == 7'b0100000) ? "SUB" : "ADD";
                    3'b001: return "SLL";
                    3'b010: return "SLT";
                    3'b011: return "SLTU";
                    3'b100: return "XOR";
                    3'b101: return (f7 == 7'b0100000) ? "SRA" : "SRL";
                    3'b110: return "OR";
                    3'b111: return "AND";
                    default: return "R-UNK";
                endcase
            end
            7'b0010011: begin // I-type immediate
                case (f3)
                    3'b000: return "ADDI";
                    3'b001: return "SLLI";
                    3'b010: return "SLTI";
                    3'b011: return "SLTIU";
                    3'b100: return "XORI";
                    3'b101: return (f7 == 7'b0100000) ? "SRAI" : "SRLI";
                    3'b110: return "ORI";
                    3'b111: return "ANDI";
                    default: return "I-UNK";
                endcase
            end
            7'b0000011: begin // Load
                case (f3)
                    3'b000: return "LB";
                    3'b001: return "LH";
                    3'b010: return "LW";
                    3'b100: return "LBU";
                    3'b101: return "LHU";
                    default: return "LOAD-UNK";
                endcase
            end
            7'b0100011: begin // Store
                case (f3)
                    3'b000: return "SB";
                    3'b001: return "SH";
                    3'b010: return "SW";
                    default: return "STORE-UNK";
                endcase
            end
            7'b1100011: begin // Branch
                case (f3)
                    3'b000: return "BEQ";
                    3'b001: return "BNE";
                    3'b100: return "BLT";
                    3'b101: return "BGE";
                    3'b110: return "BLTU";
                    3'b111: return "BGEU";
                    default: return "BRANCH-UNK";
                endcase
            end
            7'b0110111: return "LUI";
            7'b0010111: return "AUIPC";
            7'b1101111: return "JAL";
            7'b1100111: return "JALR";
            default: return "UNKNOWN";
        endcase
    endfunction
    
    // Funcion para obtener nombre de operacion ALU
    function string get_alu_op_name(logic [3:0] ctrl);
        case (ctrl)
            4'b0000: return "AND";
            4'b0001: return "OR";
            4'b0010: return "ADD";
            4'b0011: return "SLTU";
            4'b0100: return "SLT";
            4'b0110: return "SUB";
            4'b1000: return "SLL";
            4'b1001: return "XOR";
            4'b1010: return "SRL";
            4'b1011: return "SRA";
            4'b1100: return "BEQ";
            4'b1101: return "BNE";
            4'b1110: return "BLT";
            4'b1111: return "BGE";
            4'b0101: return "BLTU";
            4'b0111: return "BGEU";
            default: return "UNK";
        endcase
    endfunction
    
    // Variables auxiliares para mostrar informacion
    string instruction_str;
    string mem_op_str;
    string wb_str;
    
    // Monitor simplificado del pipeline
    always @(posedge clk) begin
        if (!rst) begin
            $display("=== Ciclo %0d ===", ($time/PERIOD) - 2);
            
            // Determinar el string de instruccion
            if (current_instruction != 0) begin
                instruction_str = get_instruction_name(opcode, func3, func7);
            end else begin
                instruction_str = "NOP";
            end
            
            // Determinar operacion de memoria
            if (dut.MemRead_MEM || dut.MemWrite_MEM) begin
                if (dut.MemWrite_MEM) begin
                    mem_op_str = "WRITE";
                end else begin
                    mem_op_str = "READ";
                end
            end else begin
                mem_op_str = "-----";
            end
            
            // Determinar writeback
            if (dut.RegWrite_WB && dut.Rd_WB != 0) begin
                wb_str = $sformatf("x%0d=0x%02h", dut.Rd_WB, dut.WriteData_WB[7:0]);
            end else begin
                wb_str = "-----";
            end
            
            // Mostrar todas las etapas en una linea
            $display("IF: PC=0x%02h  ID: %s  EX: ALU=0x%08h  MEM: %s  WB: %s", 
                    dut.PC_current[7:0],
                    instruction_str,
                    dut.ALUResult_EX,
                    mem_op_str,
                    wb_str
            );
            
            // Mostrar informacion adicional solo si es relevante
            if (dut.PCSrc) begin
                $display("    BRANCH/JUMP: Next PC = 0x%08h", dut.PC_next);
            end
            
            if (dut.MemRead_MEM || dut.MemWrite_MEM) begin
                $display("    MEMORY: Addr=0x%03h, Data=0x%08h", 
                        dut.ALUResult_MEM[11:0], 
                        dut.MemWrite_MEM ? dut.WriteData_MEM : dut.MemReadData_MEM);
            end
            
            $display("");
        end
    end
    
    // Variables para los bucles de visualizacion
    integer i;
    logic [31:0] reg_val;
    logic [31:0] instr;
    logic [6:0] op;
    logic [2:0] f3;
    logic [6:0] f7;
    logic [7:0] mem_byte;
    logic [31:0] word;
    
    // Secuencia principal de prueba
    initial begin
        $display("=== Iniciando testbench TOPPipeline ===");
        $display("Parametros: WIDTH=%0d, DEPTH_IMEM=%0d, DEPTH_DMEM=%0d", 
                WIDTH, DEPTH_IMEM, DEPTH_DMEM);
        
        // Reset inicial
        rst = 1;
        #(PERIOD * 2);
        rst = 0;
        
        $display("\n=== Reset completado, iniciando pipeline ===\n");
        
        // Ejecutar ciclos para ver el comportamiento
        #(PERIOD * 20);
        
        $display("\n=== ESTADO FINAL DE REGISTROS ===");
        $display("Registro |   Hex   |  Decimal");
        $display("---------|---------|----------");
        for (i = 0; i < 32; i = i + 1) begin
            reg_val = dut.register_file.Registers[i];
            if (reg_val != 0 || i == 0) begin
                $display("   x%2d   | 0x%08h | %10d", i, reg_val, $signed(reg_val));
            end
        end
        
        $display("\n=== INSTRUCCIONES EN MEMORIA ===");
        $display("Direccion | Instruccion | Decodificada");
        $display("----------|-------------|-------------");
        for (i = 0; i < 12; i = i + 1) begin
            instr = dut.instruction_memory.Memory[i];
            if (instr != 0) begin
                op = instr[6:0];
                f3 = instr[14:12];
                f7 = instr[31:25];
                $display("  0x%02h    | 0x%08h  | %s", 
                        i*4, instr, get_instruction_name(op, f3, f7));
            end
        end
        
        $display("\n=== MEMORIA DE DATOS ===");
        $display("Direccion | Valor (Hex) | Valor (Dec)");
        $display("----------|-------------|------------");
        for (i = 0; i < 2**(DEPTH_DMEM-2); i = i + 1) begin
            word = {dut.data_memory.DataMem[i*4+3], 
                    dut.data_memory.DataMem[i*4+2],
                    dut.data_memory.DataMem[i*4+1], 
                    dut.data_memory.DataMem[i*4]};
            if (word != 0) begin
                $display("  0x%03h   |  0x%08h  | %10d", i*4, word, $signed(word));
            end
        end
        
        $display("\n=== Testbench completado ===");
        $finish;
    end
    
    // Timeout de seguridad
    initial begin
        #(PERIOD * 50);
        $display("TIMEOUT: Testbench terminado por limite de tiempo");
        $finish;
    end
    
    // Sistema de guardado
    initial begin
        $dumpfile("TOPPipeline_tb.vcd");
        $dumpvars(0, TOPPipeline_tb);
    end 
    
endmodule