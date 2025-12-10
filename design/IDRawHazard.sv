module IDRawHazard #(
    parameter WIDTH = 5    // Ancho de direcciones de registro (5 bits para RISC-V)
)(
    input  logic [WIDTH-1:0] WriteRegWB,  // Registro destino en Writeback
    input  logic [WIDTH-1:0] Rs1ID,       // Registro fuente 1 en Decode
    input  logic [WIDTH-1:0] Rs2ID,       // Registro fuente 2 en Decode
    input  logic             RegWriteW,   // Writeback escribirá registro
    input  logic             rst,         // Reset (desactiva detección)
    output logic             IDHazardStall // Señal de stall
);

    // Señales intermedias
    logic rs1_match, rs2_match;
    logic valid_hazard_rs1, valid_hazard_rs2;
    logic any_match;

    // Comparar direcciones
    assign rs1_match = (Rs1ID == WriteRegWB);
    assign rs2_match = (Rs2ID == WriteRegWB);

    /*
     * Hazard válido solo si:
     * - Hay match de direcciones
     * - El registro fuente NO es x0
     * - El registro destino NO es x0
     */
    assign valid_hazard_rs1 = rs1_match && (Rs1ID != {WIDTH{1'b0}}) && 
                              (WriteRegWB != {WIDTH{1'b0}});
    
    assign valid_hazard_rs2 = rs2_match && (Rs2ID != {WIDTH{1'b0}}) && 
                              (WriteRegWB != {WIDTH{1'b0}});

    // Cualquier hazard válido
    assign any_match = valid_hazard_rs1 | valid_hazard_rs2;

    /*
     * Stall final:
     * - Debe haber hazard válido
     * - Debe haber escritura en Writeback
     * - Reset debe estar inactivo
     */
    assign IDHazardStall = any_match & RegWriteW & ~rst;

    // Verificación y debug en simulación
    // synthesis translate_off
    
    int hazard_count = 0;
    int rs1_hazard_count = 0;
    int rs2_hazard_count = 0;
    
    always_ff @(posedge IDHazardStall) begin
        hazard_count++;
        
        $display("[ID RAW HAZARD] Time=%0t: Stall detectado", $time);
        $display("  WriteRegWB = x%0d", WriteRegWB);
        
        if (valid_hazard_rs1) begin
            rs1_hazard_count++;
            $display("  Rs1 (x%0d) depende de WriteRegWB", Rs1ID);
        end
        
        if (valid_hazard_rs2) begin
            rs2_hazard_count++;
            $display("  Rs2 (x%0d) depende de WriteRegWB", Rs2ID);
        end
    end
    
    // Verificar que x0 nunca cause hazard
    always_comb begin
        if (IDHazardStall && (Rs1ID == 5'b0 || Rs2ID == 5'b0 || WriteRegWB == 5'b0)) begin
            $error("Time=%0t: x0 causando hazard (error de lógica)", $time);
        end
    end
    
    final begin
        $display("=== ID RAW Hazard Statistics ===");
        $display("Total hazards: %0d", hazard_count);
        $display("Rs1 hazards: %0d", rs1_hazard_count);
        $display("Rs2 hazards: %0d", rs2_hazard_count);
    end
    
    // synthesis translate_on

endmodule
