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
    
endmodule