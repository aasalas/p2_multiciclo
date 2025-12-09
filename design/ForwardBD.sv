module Forward_BD (
    input logic [4:0] rtD,       
    input logic WRM_eq_rtD,      
    input logic RegWriteM,       
    output logic ForwardBD      
);


assign ForwardBD = RegWriteM & WRM_eq_rtD & (|rtD);

endmodule