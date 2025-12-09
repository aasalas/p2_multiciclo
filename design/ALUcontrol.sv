module ALUControl (
    input logic [1:0] ALUOp,        // Del Control principal
    input logic [2:0] func3,        // De la instrucción
    input logic [6:0] func7,        // De la instrucción
    output logic [3:0] ALUCtrl      // Señal de control para ALU
);

    always_comb begin
        case (ALUOp)
            2'b00: begin // Load/Store/LUI/AUIPC/JAL/JALR
                ALUCtrl = 4'b0010; // ADD para direcciones / LUI pasa inmediato
            end
            
            2'b01: begin // Branch - comparaciones
                case (func3)
                    3'b000: ALUCtrl = 4'b1100; // BEQ - comparación igualdad
                    3'b001: ALUCtrl = 4'b1101; // BNE - comparación desigualdad
                    3'b100: ALUCtrl = 4'b1110; // BLT - menor que signed
                    3'b101: ALUCtrl = 4'b1111; // BGE - mayor igual signed
                    3'b110: ALUCtrl = 4'b0101; // BLTU - menor que unsigned
                    3'b111: ALUCtrl = 4'b0111; // BGEU - mayor igual unsigned
                    default: ALUCtrl = 4'b1100; // Default: BEQ
                endcase
            end
            
            2'b10: begin // R-type - operaciones registro-registro
                case (func3)
                    3'b000: begin // ADD/SUB
                        if (func7 == 7'b0100000)
                            ALUCtrl = 4'b0110; // SUB
                        else
                            ALUCtrl = 4'b0010; // ADD
                    end
                    3'b001: ALUCtrl = 4'b1000; // SLL
                    3'b010: ALUCtrl = 4'b0100; // SLT
                    3'b011: ALUCtrl = 4'b0011; // SLTU
                    3'b100: ALUCtrl = 4'b1001; // XOR
                    3'b101: begin // SRL/SRA
                        if (func7 == 7'b0100000)
                            ALUCtrl = 4'b1011; // SRA
                        else
                            ALUCtrl = 4'b1010; // SRL
                    end
                    3'b110: ALUCtrl = 4'b0001; // OR
                    3'b111: ALUCtrl = 4'b0000; // AND
                    default: ALUCtrl = 4'b0010; // Default: ADD
                endcase
            end
            
            2'b11: begin // I-type immediate - similar a R-type
                case (func3)
                    3'b000: ALUCtrl = 4'b0010; // ADDI
                    3'b001: ALUCtrl = 4'b1000; // SLLI
                    3'b010: ALUCtrl = 4'b0100; // SLTI
                    3'b011: ALUCtrl = 4'b0011; // SLTIU
                    3'b100: ALUCtrl = 4'b1001; // XORI
                    3'b101: begin // SRLI/SRAI
                        if (func7 == 7'b0100000)
                            ALUCtrl = 4'b1011; // SRAI
                        else
                            ALUCtrl = 4'b1010; // SRLI
                    end
                    3'b110: ALUCtrl = 4'b0001; // ORI
                    3'b111: ALUCtrl = 4'b0000; // ANDI
                    default: ALUCtrl = 4'b0010; // Default: ADD
                endcase
            end
            
            default: ALUCtrl = 4'b0010; // Default: ADD
        endcase
    end
endmodule