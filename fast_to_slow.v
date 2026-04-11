`timescale 1ns/1ps

module fast_to_slow_problem(
    input clk_fast,
    input clk_slow,
    input rst_n,
    input pulse_fast,
    output reg pulse_slow
);

// Direct sampling (WRONG)
always @(posedge clk_slow or negedge rst_n) begin
    if (!rst_n)
        pulse_slow <= 0;
    else
        pulse_slow <= pulse_fast;  // ❌ may miss pulse
end

endmodule

//testbench
`timescale 1ns/1ps

module tb_fast_to_slow;

reg clk_fast;
reg clk_slow;
reg rst_n;
reg pulse_fast;

wire pulse_slow;

// DUT
fast_to_slow_problem dut (
    .clk_fast(clk_fast),
    .clk_slow(clk_slow),
    .rst_n(rst_n),
    .pulse_fast(pulse_fast),
    .pulse_slow(pulse_slow)
);

//////////////////////////////////////////////////////////
// Clock Generation
//////////////////////////////////////////////////////////

// Fast clock (100 MHz)
always #5 clk_fast = ~clk_fast;

// Slow clock (25 MHz)
always #20 clk_slow = ~clk_slow;

//////////////////////////////////////////////////////////
// Stimulus
//////////////////////////////////////////////////////////

initial begin
    // Proper initialization
    clk_fast   = 0;
    clk_slow   = 0;
    rst_n      = 0;
    pulse_fast = 0;

    // Release reset
    #20;
    rst_n = 1;

    // Generate pulses in fast domain
    repeat (10) begin
        @(posedge clk_fast);
        pulse_fast = 1;

        @(posedge clk_fast);
        pulse_fast = 0;

        // Small gap
        repeat (2) @(posedge clk_fast);
    end

    #200;
    $stop;
end

//////////////////////////////////////////////////////////
// Monitor (optional)
//////////////////////////////////////////////////////////

initial begin
    $monitor("Time=%0t | pulse_fast=%b | pulse_slow=%b",
              $time, pulse_fast, pulse_slow);
end

endmodule
