module tb;
  logic clk = 0; logic rst = 1;
  always #5 clk = ~clk;

  cpu_top cpu(.clk(clk), .rst(rst));


  
  initial begin
    rst = 1; #20; rst = 0;
    // load a small program into instr_mem by poking hierarchical mem from testbench
    // Example program: ADDI x1,x0,5 ; ADDI x2,x0,10 ; ADD x3,x1,x2 ; SW x3,0(x0) ; LW x4,0(x0)
    // Machine code values (little-endian word) must be provided; below values are placeholders and should be replaced with proper encodings.
    $display("Starting simulation");
    #1000; 
    $finish;
  end
endmodule