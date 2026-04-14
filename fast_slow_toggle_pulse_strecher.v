module cdc_toggle_sync (
    input  wire clk_fast,
    input  wire clk_slow,
    input  wire rst_n,
    input  wire pulse_fast,
    output wire pulse_slow   // one pulse per event
);

    // ----------------------------------
    // FAST DOMAIN: Toggle Generator
    // ----------------------------------
    reg toggle;

    always @(posedge clk_fast or negedge rst_n) begin
        if (!rst_n)
            toggle <= 1'b0;
        else if (pulse_fast)
            toggle <= ~toggle;   // toggle on every pulse
    end

    // ----------------------------------
    // SLOW DOMAIN: Synchronizer
    // ----------------------------------
    reg sync_ff1, sync_ff2;

    always @(posedge clk_slow or negedge rst_n) begin
        if (!rst_n) begin
            sync_ff1 <= 0;
            sync_ff2 <= 0;
        end else begin
            sync_ff1 <= toggle;
            sync_ff2 <= sync_ff1;
        end
    end

    // ----------------------------------
    // EDGE DETECTION (Pulse generation)
    // ----------------------------------
    assign pulse_slow = sync_ff1 ^ sync_ff2;

endmodule

//testbench
`timescale 1ns/1ps

module tb_toggle_sync;

    reg clk_fast;
    reg clk_slow;
    reg rst_n;
    reg pulse_fast;

    wire pulse_slow;

    cdc_toggle_sync dut (
        .clk_fast(clk_fast),
        .clk_slow(clk_slow),
        .rst_n(rst_n),
        .pulse_fast(pulse_fast),
        .pulse_slow(pulse_slow)
    );

    // Fast clock (4ns)
    initial begin
        clk_fast = 0;
        forever #2 clk_fast = ~clk_fast;
    end

    // Slow clock (20ns)
    initial begin
        clk_slow = 0;
        forever #10 clk_slow = ~clk_slow;
    end

    initial begin
        rst_n = 0;
        pulse_fast = 0;

        #20;
        rst_n = 1;

        // Generate multiple close pulses
        repeat (6) begin
    @(posedge clk_fast);
    pulse_fast = 1;

    @(posedge clk_fast);
    pulse_fast = 0;

    repeat (10) @(posedge clk_fast); // increase gap
end

        #2000;
        $finish;
    end

    initial begin
        $monitor("T=%0t | fast=%b | slow=%b",
                 $time, pulse_fast, pulse_slow);
    end

endmodule
