module cdc_convergence_bad (
    input rst,
    input clk_b,
    input sig_a, // From domain A
    input sig_b, // From domain A
    output reg out_b
);

    wire combined_net;

    // Convergence happens here. 
    // If sig_a and sig_b change near the clk_b edge, 
    // combined_net will glitch.
    assign combined_net = sig_a & sig_b;

    always @(posedge clk_b or negedge rst) 
      begin
       if ( !rst) 
        out_b <= 1'b0;
       else
        out_b <= combined_net;
      end

endmodule
//test bench 
// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module tb_cdc_convergence_bad();
reg rst;
    reg clk_b;
    reg sig_a, sig_b;
    wire out_b;

    // Instantiate the bad module
    cdc_convergence_bad uut (
    .rst(rst),
        .clk_b(clk_b),
        .sig_a(sig_a),
        .sig_b(sig_b),
        .out_b(out_b)
    );

    // Generate clk_b (100 MHz)
    initial clk_b = 0;
    always #5 clk_b = ~clk_b;
     
    initial begin
        // Initialize signals
        sig_a = 0;
        sig_b = 0;
        rst = 0;
        $monitor("Time=%0t | sig_a=%b sig_b=%b | out_b=%b", $time, sig_a, sig_b, out_b);
        // Wait a few cycles
        #10;
        rst = 1'b1;

        // Scenario: Signals change very close to each other 
        // but are NOT aligned to clk_b.
        #3 sig_a = 1;
        #1 sig_b = 1; // Both are 1 now, 'combined_net' in UUT goes high
        
        #15;
        sig_a = 0;
        sig_b = 0;

        #50 $finish;
    end
endmodule
