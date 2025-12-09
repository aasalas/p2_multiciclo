module branchstall (
    input logic WRE_eq_rsD,
    input logic WRE_eq_rtD,
    input logic RegWriteE,
    input logic BranchD,
    input logic WRM_eq_rsD,
    input logic WRM_eq_rtD,
    input logic MemtoRegM,
    output logic branch_stall
);

logic ALU_hazard;
logic lw_hazard;


assign ALU_hazard = BranchD & RegWriteE & (WRE_eq_rsD | WRE_eq_rtD);
assign lw_hazard = BranchD & MemtoRegM & (WRM_eq_rsD | WRM_eq_rtD);
assign branch_stall = ALU_hazard | lw_hazard;


endmodule