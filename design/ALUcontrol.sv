module ALUControl (
    input  logic [1:0] ALUOp,        // Del Control principal
    input  logic [2:0] func3,        // De la instrucción
    input  logic [6:0] func7,        // De la instrucción
    output logic [3:0] ALUCtrl       // Señal de control para ALU
);

    // Constantes locales para mejor legibilidad (solo interno)
    localparam logic [3:0] 
        ALU_AND  = 4'b0000,
        ALU_OR   = 4'b0001,
        ALU_ADD  = 4'b0010,
        ALU_SLTU = 4'b0011,
        ALU_SLT  = 4'b0100,
        ALU_BLTU = 4'b0101,
        ALU_SUB  = 4'b0110,
        ALU_BGEU = 4'b0111,
        ALU_SLL  = 4'b1000,
        ALU_XOR  = 4'b1001,
        ALU_SRL  = 4'b1010,
        ALU_SRA  = 4'b1011,
        ALU_BEQ  = 4'b1100,
        ALU_BNE  = 4'b1101,
        ALU_BLT  = 4'b1110,
        ALU_BGE  = 4'b1111;
    
    localparam logic [1:0]
        ALUOP_MEM    = 2'b00,  // Load/Store/LUI/AUIPC/JAL/JALR
        ALUOP_BRANCH = 2'b01,  // Branch instructions
        ALUOP_RTYPE  = 2'b10,  // R-type operations
        ALUOP_ITYPE  = 2'b11;  // I-type immediate operations

    // Señales internas para claridad
    logic is_sub_or_sra;
    
    assign is_sub_or_sra = (func7 == 7'b0100000);

    always_comb begin
        case (ALUOp)
            ALUOP_MEM: begin // 2'b00
                // Load/Store/LUI/AUIPC/JAL/JALR - siempre ADD
                ALUCtrl = ALU_ADD; // 4'b0010
            end
            
            ALUOP_BRANCH: begin // 2'b01
                // Branch - comparaciones
                case (func3)
                    3'b000: ALUCtrl = ALU_BEQ;  // 4'b1100 - BEQ
                    3'b001: ALUCtrl = ALU_BNE;  // 4'b1101 - BNE
                    3'b100: ALUCtrl = ALU_BLT;  // 4'b1110 - BLT
                    3'b101: ALUCtrl = ALU_BGE;  // 4'b1111 - BGE
                    3'b110: ALUCtrl = ALU_BLTU; // 4'b0101 - BLTU
                    3'b111: ALUCtrl = ALU_BGEU; // 4'b0111 - BGEU
                    default: ALUCtrl = ALU_BEQ; // 4'b1100 - Default
                endcase
            end
            
            ALUOP_RTYPE, ALUOP_ITYPE: begin // 2'b10 o 2'b11
                // R-type e I-type comparten la misma lógica
                // Solo difieren en que I-type no tiene SUB (siempre ADDI)
                case (func3)
                    3'b000: begin // ADD/SUB/ADDI
                        // SUB solo existe en R-type (ALUOp == 2'b10)
                        if (is_sub_or_sra && (ALUOp == ALUOP_RTYPE))
                            ALUCtrl = ALU_SUB; // 4'b0110
                        else
                            ALUCtrl = ALU_ADD; // 4'b0010
                    end
                    3'b001: ALUCtrl = ALU_SLL;  // 4'b1000 - SLL/SLLI
                    3'b010: ALUCtrl = ALU_SLT;  // 4'b0100 - SLT/SLTI
                    3'b011: ALUCtrl = ALU_SLTU; // 4'b0011 - SLTU/SLTIU
                    3'b100: ALUCtrl = ALU_XOR;  // 4'b1001 - XOR/XORI
                    3'b101: begin // SRL/SRA/SRLI/SRAI
                        if (is_sub_or_sra)
                            ALUCtrl = ALU_SRA; // 4'b1011
                        else
                            ALUCtrl = ALU_SRL; // 4'b1010
                    end
                    3'b110: ALUCtrl = ALU_OR;   // 4'b0001 - OR/ORI
                    3'b111: ALUCtrl = ALU_AND;  // 4'b0000 - AND/ANDI
                    default: ALUCtrl = ALU_ADD; // 4'b0010 - Default
                endcase
            end
            
            default: ALUCtrl = ALU_ADD; // 4'b0010 - Default seguro
        endcase
    end

endmodule