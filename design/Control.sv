module Control (
    input logic [6:0] opcode,
    input logic [2:0] func3,    
    
    // Señales de control del datapath
    output logic RegWrite,      // Escribir en registro destino
    output logic ALUSrc,        // 0: Rs2, 1: Inmediato para ALU
    output logic MemRead,       // Leer de memoria
    output logic MemWrite,      // Escribir a memoria  
    output logic MemtoReg,      // 0: ALU result, 1: Mem data a registro
    output logic Branch,        // Instrucción de branch
    output logic Jump,          // Instrucción de jump
    output logic [1:0] ALUOp,   // Tipo de operación para ALUControl
    output logic one_byte,      // Para sb, lb, lbu
    output logic two_byte,      // Para sh, lh, lhu
    output logic four_bytes,    // Para sw, lw
    output logic unsigned_load  // Para lbu, lhu
);

    always_comb begin
        // Valores por defecto (evita latches)
        RegWrite = 1'b0;
        ALUSrc = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        MemtoReg = 1'b0;
        Branch = 1'b0;
        Jump = 1'b0;
        ALUOp = 2'b00;
        one_byte = 1'b0;
        two_byte = 1'b0;
        four_bytes = 1'b0;
        unsigned_load = 1'b0;
        
        case (opcode)
            // R-type: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
            7'b0110011: begin
                RegWrite = 1'b1;    // Escribir resultado en Rd
                ALUSrc = 1'b0;      // Usar Rs2 (no inmediato)
                MemtoReg = 1'b0;    // Resultado de ALU a registro
                ALUOp = 2'b10;      // R-type: usar func3/func7
            end
            
            // I-type Load: LW, LH, LB, LHU, LBU
            7'b0000011: begin
                RegWrite = 1'b1;    // Escribir dato leído en Rd
                ALUSrc = 1'b1;      // Usar inmediato para dirección
                MemRead = 1'b1;     // Leer de memoria
                MemtoReg = 1'b1;    // Dato de memoria a registro
                ALUOp = 2'b00;      // Suma simple para dirección
                
                // Decodificar tipo de load según func3
                case (func3)
                    3'b000: begin   // LB - Load Byte
                        one_byte = 1'b1;
                        unsigned_load = 1'b0;  // Con signo
                    end
                    3'b001: begin   // LH - Load Halfword
                        two_byte = 1'b1;
                        unsigned_load = 1'b0;  // Con signo
                    end
                    3'b010: begin   // LW - Load Word
                        four_bytes = 1'b1;
                    end
                    3'b100: begin   // LBU - Load Byte Unsigned
                        one_byte = 1'b1;
                        unsigned_load = 1'b1;  // Sin signo
                    end
                    3'b101: begin   // LHU - Load Halfword Unsigned
                        two_byte = 1'b1;
                        unsigned_load = 1'b1;  // Sin signo
                    end
                    default: begin
                        // Caso por defecto - LW
                        four_bytes = 1'b1;
                    end
                endcase
            end
            
            // I-type Immediate: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            7'b0010011: begin
                RegWrite = 1'b1;    // Escribir resultado en Rd
                ALUSrc = 1'b1;      // Usar inmediato
                MemtoReg = 1'b0;    // Resultado de ALU a registro
                ALUOp = 2'b11;      // I-type: usar func3 (similar a R-type)
            end
            
            // S-type Store: SW, SH, SB
            7'b0100011: begin
                ALUSrc = 1'b1;      // Usar inmediato para dirección
                MemWrite = 1'b1;    // Escribir a memoria
                ALUOp = 2'b00;      // Suma simple para dirección
                
                // Decodificar tipo de store según func3
                case (func3)
                    3'b000: begin   // SB - Store Byte
                        one_byte = 1'b1;
                    end
                    3'b001: begin   // SH - Store Halfword
                        two_byte = 1'b1;
                    end
                    3'b010: begin   // SW - Store Word
                        four_bytes = 1'b1;
                    end
                    default: begin
                        // Caso por defecto - SW
                        four_bytes = 1'b1;
                    end
                endcase
            end
            
            // B-type Branch: BEQ, BNE, BLT, BGE, BLTU, BGEU
            7'b1100011: begin
                ALUSrc = 1'b0;      // Comparar Rs1 con Rs2
                Branch = 1'b1;      // Es branch
                ALUOp = 2'b01;      // Branch: usar func3 para comparación
            end
            
            // U-type: LUI - Load Upper Immediate
            7'b0110111: begin
                RegWrite = 1'b1;    // Escribir inmediato en Rd
                ALUSrc = 1'b1;      // Usar inmediato
                MemtoReg = 1'b0;    // Resultado de ALU a registro
                ALUOp = 2'b00;      // Pasar inmediato directamente
            end
            
            // U-type: AUIPC - Add Upper Immediate to PC
            7'b0010111: begin
                RegWrite = 1'b1;    // Escribir PC+inmediato en Rd
                ALUSrc = 1'b1;      // Usar inmediato
                MemtoReg = 1'b0;    // Resultado de ALU a registro
                ALUOp = 2'b00;      // Suma PC + inmediato
            end
            
            // J-type: JAL - Jump and Link
            7'b1101111: begin
                RegWrite = 1'b1;    // Escribir PC+4 en Rd
                Jump = 1'b1;        // Es jump
                MemtoReg = 1'b0;    // PC+4 a registro
                ALUOp = 2'b00;      // No usar ALU para cálculo
            end
            
            // I-type: JALR - Jump and Link Register
            7'b1100111: begin
                RegWrite = 1'b1;    // Escribir PC+4 en Rd
                ALUSrc = 1'b1;      // Usar inmediato
                Jump = 1'b1;        // Es jump
                MemtoReg = 1'b0;    // PC+4 a registro
                ALUOp = 2'b00;      // Suma Rs1 + inmediato
            end
        endcase
    end
endmodule