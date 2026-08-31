module cdc_fast_to_slow (
    input  wire clk_fast,     // fast clock (source domain)
    input  wire clk_slow,     // slow clock (destination domain)
    input  wire rst_n,        // active low reset
    input  wire pulse_fast,   // pulse in fast domain
    output wire pulse_slow    // synchronized output in slow domain
);

    // ----------------------------------
    // Pulse Stretcher (FAST DOMAIN)
    // ----------------------------------
    reg [3:0] stretch_cnt;
    reg stretched;

    always @(posedge clk_fast or negedge rst_n) begin
        if (!rst_n) begin
            stretch_cnt <= 4'd0;
            stretched   <= 1'b0;
        end else begin
            if (pulse_fast)
                stretch_cnt <= 4'd8;  // stretch for 8 fast cycles
            else if (stretch_cnt != 0)
                stretch_cnt <= stretch_cnt - 1;

            stretched <= (stretch_cnt != 0);
        end
    end

    // ----------------------------------
    // 2-FF Synchronizer (SLOW DOMAIN)
    // ----------------------------------
    reg sync_ff1, sync_ff2;

    always @(posedge clk_slow or negedge rst_n) begin
        if (!rst_n) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
        end else begin
            sync_ff1 <= stretched;
            sync_ff2 <= sync_ff1;
        end
    end

    assign pulse_slow = sync_ff2;

endmodule
//testbench
`timescale 1ns/1ps

module tb_cdc_fast_to_slow;

    reg clk_fast;
    reg clk_slow;
    reg rst_n;
    reg pulse_fast;

    wire pulse_slow;

    // DUT instantiation
    cdc_fast_to_slow dut (
        .clk_fast(clk_fast),
        .clk_slow(clk_slow),
        .rst_n(rst_n),
        .pulse_fast(pulse_fast),
        .pulse_slow(pulse_slow)
    );

    // -------------------------------
    // FAST CLOCK (4ns period)
    // -------------------------------
    initial begin
        clk_fast = 0;
        forever #2 clk_fast = ~clk_fast;
    end

    // -------------------------------
    // SLOW CLOCK (20ns period)
    // -------------------------------
    initial begin
        clk_slow = 0;
        forever #10 clk_slow = ~clk_slow;
    end

    // -------------------------------
    // STIMULUS
    // -------------------------------
    initial begin
        rst_n = 0;
        pulse_fast = 0;

        #20;
        rst_n = 1;

        // Generate pulses
        repeat (5) begin
            @(posedge clk_fast);
            pulse_fast = 1;

            @(posedge clk_fast);
            pulse_fast = 0;

            repeat (5) @(posedge clk_fast);
        end

        #200;
        $finish;
    end

    // -------------------------------
    // MONITOR
    // -------------------------------
    initial begin
        $monitor("T=%0t | fast=%b | slow=%b",
                 $time, pulse_fast, pulse_slow);
    end

endmodule

