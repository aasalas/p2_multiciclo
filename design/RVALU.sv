module RVALU #(parameter WIDTH = 32) (
    input  logic [WIDTH-1:0] a, b,
    input  logic [3:0]       ALUCtrl,
    output logic [WIDTH-1:0] ALUResult,
    output logic             Zero, Comparison
);

    // Códigos de operación ALU
    localparam AND  = 4'b0000;
    localparam OR   = 4'b0001;
    localparam ADD  = 4'b0010;
    localparam SLTU = 4'b0011;
    localparam SLT  = 4'b0100;
    localparam BLTU = 4'b0101;
    localparam SUB  = 4'b0110;
    localparam BGEU = 4'b0111;
    localparam SLL  = 4'b1000;
    localparam XOR  = 4'b1001;
    localparam SRL  = 4'b1010;
    localparam SRA  = 4'b1011;
    localparam BEQ  = 4'b1100;
    localparam BNE  = 4'b1101;
    localparam BLT  = 4'b1110;
    localparam BGE  = 4'b1111;

    logic [WIDTH-1:0] result_alu;
    logic             comp_branch;

    always_comb begin
        case (ALUCtrl)
            // Aritmética
            AND:  result_alu = a & b;
            OR:   result_alu = a | b;
            XOR:  result_alu = a ^ b;
            ADD:  result_alu = $signed(a) + $signed(b);
            SUB:  result_alu = $signed(a) - $signed(b);
            
            // Shift
            SLL:  result_alu = a << b[4:0];
            SRL:  result_alu = a >> b[4:0];
            SRA:  result_alu = $signed(a) >>> b[4:0];
            
            // Set on Less Than
            SLT:  result_alu = {{WIDTH-1{1'b0}}, ($signed(a) < $signed(b))};
            SLTU: result_alu = {{WIDTH-1{1'b0}}, (a < b)};
            
            // Branch comparisons (resultado ignorado, solo usa Comparison)
            BEQ:  result_alu = '0;
            BNE:  result_alu = '0;
            BLT:  result_alu = '0;
            BGE:  result_alu = '0;
            BLTU: result_alu = '0;
            BGEU: result_alu = '0;
            
            default: result_alu = $signed(a) + $signed(b); // ADD por defecto
        endcase
    end

    // Lógica de comparación para branches
    always_comb begin
        case (ALUCtrl)
            BEQ:  comp_branch = ($signed(a) == $signed(b));
            BNE:  comp_branch = ($signed(a) != $signed(b));
            BLT:  comp_branch = ($signed(a) < $signed(b));
            BGE:  comp_branch = ($signed(a) >= $signed(b));
            BLTU: comp_branch = (a < b);
            BGEU: comp_branch = (a >= b);
            default: comp_branch = 1'b0;
        endcase
    end

    // Salidas: asignaciones continuas
    assign ALUResult = result_alu;
    assign Comparison = comp_branch;
    assign Zero = (result_alu == '0);

endmodule

