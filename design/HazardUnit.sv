module HazardUnit (
    // Señales de hazard de diferentes unidades
    input  logic IDHazardStall,    // Hazard RAW en Decode-Writeback
    input  logic lwstall,          // Load-use hazard
    input  logic branchstall,      // Branch data hazard
    
    // Señales de control del pipeline
    output logic StallF,           // Congelar etapa Fetch
    output logic StallD,           // Congelar etapa Decode
    output logic FlushE            // Insertar bubble en Execute
);

    // Cualquier hazard causa stall completo
    logic any_hazard;
    assign any_hazard = lwstall | branchstall | IDHazardStall;
    
    // Todas las señales son idénticas porque cualquier hazard
    // requiere la misma respuesta: stall de 1 ciclo
    assign StallF = any_hazard;
    assign StallD = any_hazard;
    assign FlushE = any_hazard;

    // Estadísticas en simulación
    // synthesis translate_off
    
    int total_stalls = 0;
    int lw_stall_count = 0;
    int branch_stall_count = 0;
    int id_hazard_count = 0;
    
    always_ff @(posedge any_hazard) begin
        total_stalls++;
        
        // Contar cada tipo (pueden superponerse)
        if (lwstall) lw_stall_count++;
        if (branchstall) branch_stall_count++;
        if (IDHazardStall) id_hazard_count++;
        
        // Reportar hazard
        $display("[HAZARD UNIT] Time=%0t: Pipeline stalled", $time);
        if (lwstall) $display("  - Load-use hazard");
        if (branchstall) $display("  - Branch data hazard");
        if (IDHazardStall) $display("  - ID RAW hazard");
    end
    
    // Reporte final
    /*final begin
        $display("=== Hazard Unit Statistics ===");
        $display("Total stalls: %0d", total_stalls);
        $display("Load-use stalls: %0d", lw_stall_count);
        $display("Branch stalls: %0d", branch_stall_count);
        $display("ID hazard stalls: %0d", id_hazard_count);
        
        if (total_stalls > 0) begin
            real lw_percent = (100.0 * lw_stall_count) / total_stalls;
            real branch_percent = (100.0 * branch_stall_count) / total_stalls;
            real id_percent = (100.0 * id_hazard_count) / total_stalls;
            
            $display("Load-use: %.1f%%", lw_percent);
            $display("Branch: %.1f%%", branch_percent);
            $display("ID hazard: %.1f%%", id_percent);
        end
    end*/
    

endmodule