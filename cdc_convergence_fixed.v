// GOOD: Synchronize each signal independently before logic
module cdc_convergence_fixed (
    input clk_b,
    input sig_a, // From domain A
    input sig_b, // From domain A
    output reg out_b
);

    // Synchronizer registers for Signal A
    reg sig_a_meta;
    reg sig_a_sync;

    // Synchronizer registers for Signal B
    reg sig_b_meta;
    reg sig_b_sync;

    // 2-FF Synchronizer for Signal A
    always @(posedge clk_b) begin
        sig_a_meta <= sig_a;
        sig_a_sync <= sig_a_meta;
    end

    // 2-FF Synchronizer for Signal B
    always @(posedge clk_b) begin
        sig_b_meta <= sig_b;
        sig_b_sync <= sig_b_meta;
    end

    // Safe Convergence
    // The logic is performed on signals already stable in clk_b
    always @(posedge clk_b) begin
        out_b <= sig_a_sync & sig_b_sync;
    end
// testbench
`timescale 1ns/1ps

module tb_cdc_convergence_fixed();
    reg clk_a, clk_b;
    reg src_a, src_b;
    wire out_b;

    // Instantiate the fixed module
    cdc_convergence_fixed uut (
        .clk_b(clk_b),
        .sig_a(src_a),
        .sig_b(src_b),
        .out_b(out_b)
    );

    // clk_a: ~123 MHz (approx 8.1ns period)
    initial clk_a = 0;
    always #4.05 clk_a = ~clk_a;

    // clk_b: 100 MHz (10ns period)
    initial clk_b = 0;
    always #5.0 clk_b = ~clk_b;

    // Drive signals from clk_a domain
    initial begin
        src_a = 0;
        src_b = 0;
        
        repeat(5) @(posedge clk_a);
        
        // Assert signals in domain A
        @(posedge clk_a);
        src_a <= 1;
        repeat(2) @(posedge clk_a);
        src_b <= 1;

        // Wait to see synchronization cycles in domain B
        repeat(10) @(posedge clk_b);
        
        src_a <= 0;
        src_b <= 0;

        #100 $finish;
    end

    // Visualize the 2-FF delay
    initial begin
        $display("Monitoring synchronization delay...");
        $monitor("Time=%0t | clk_b Edge | src_a=%b src_b=%b | out_b=%b", $time, src_a, src_b, out_b);
    end
endmodule
endmodule
