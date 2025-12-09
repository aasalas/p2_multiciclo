module Forward_AD (
    input logic [4:0] rsD,       
    input logic WRM_eq_rsD,      
    input logic RegWriteM,       
    output logic ForwardAD       
);


assign ForwardAD = RegWriteM & WRM_eq_rsD & (|rsD);

endmodule