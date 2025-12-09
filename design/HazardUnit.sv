module HazardUnit (
    input logic IDHazardStall,
    input logic lwstall,
    input logic branchstall,
    output logic StallF,
    output logic StallD,
    output logic FlushE
);


assign StallF = lwstall | branchstall | IDHazardStall;
assign StallD = lwstall | branchstall | IDHazardStall;
assign FlushE = lwstall | branchstall | IDHazardStall;

endmodule