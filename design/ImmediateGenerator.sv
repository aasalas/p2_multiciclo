// Generador de inmediatos para diferentes propósitos dentro del procesador componente combinacional
module ImmediateGenerator #(parameter WIDTH=32)
(
    input logic [6:0] Opcode,
    input logic [WIDTH-1:0] instruction,
    output logic [WIDTH-1:0] ImmExt
);

// Señales intermedias para evitar selecciones constantes en always_comb
logic [11:0] i_type_imm;
logic [11:0] s_type_imm;
logic [12:0] b_type_imm;
logic [19:0] u_type_imm;
logic [20:0] j_type_imm;

// Extraer campos de inmediatos fuera del always_comb
assign i_type_imm = instruction[31:20];
assign s_type_imm = {instruction[31:25], instruction[11:7]};
assign b_type_imm = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
assign u_type_imm = instruction[31:12];
assign j_type_imm = {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};

// Señales para extensión de signo
logic sign_i, sign_s, sign_b, sign_j;
assign sign_i = i_type_imm[11];
assign sign_s = s_type_imm[11];
assign sign_b = b_type_imm[12];
assign sign_j = j_type_imm[20];

always_comb begin
    case (Opcode)
        // Tipo I (e.g., lw, addi, jalr) - inmediato en [31:20] (12 bits)
        7'b0000011,  // LOAD
        7'b0010011,  // OP-IMM (addi, slti, etc.)
        7'b1100111:  // JALR
        begin
            ImmExt = {{(WIDTH-12){sign_i}}, i_type_imm};
        end
        
        // Tipo S (e.g., sw) - inmediato en [31:25] y [11:7]
        7'b0100011:  // STORE
        begin
            ImmExt = {{(WIDTH-12){sign_s}}, s_type_imm};
        end
        
        // Tipo B (e.g., beq, bne) - inmediato disperso: [31], [7], [30:25], [11:8]
        7'b1100011:  // BRANCH
        begin
            ImmExt = {{(WIDTH-13){sign_b}}, b_type_imm};
        end
        
        // Tipo U (e.g., lui, auipc) - inmediato en [31:12], parte baja en 0
        7'b0110111,  // LUI
        7'b0010111:  // AUIPC
        begin
            ImmExt = {u_type_imm, 12'b0};       // 20 bits superiores + 12 ceros
        end
        
        // Tipo J (e.g., jal) - inmediato disperso: [31], [19:12], [20], [30:21]
        7'b1101111:  // JAL
        begin
            ImmExt = {{(WIDTH-21){sign_j}}, j_type_imm};
        end
        
        // Default: todos los bits en 0
        default: ImmExt = {WIDTH{1'b0}};
    endcase
end

endmodule

