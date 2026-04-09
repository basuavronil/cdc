// 2 flipflop synchronization to counter clock domain crossing
module simple_cdc (
    input  clk_dest,   // Destination clock
    input  rst_n,      // Active low reset
    input async_in,    // Async input
    output sync_out    // Output
);
    reg ff1, ff2;
always @(posedge clk_dest or negedge rst_n) begin
    if (!rst_n) begin
        ff1 <= 0;
        ff2 <= 0;
    end else begin
        ff1 <= async_in;
        ff2 <= ff1;
    end
end
assign sync_out = ff2;
endmodule

// testbench 
`timescale 1ns/1ps
module tb_simple_cdc;
    reg clk_dest;
    reg rst_n;
    reg async_in;
    wire sync_out;
  
    // Instantiate DUT
    simple_cdc dut (
        .clk_dest(clk_dest),
        .rst_n(rst_n),
        .async_in(async_in),
        .sync_out(sync_out)
    );

    // Clock generation (10ns period)
    initial begin
        clk_dest = 0;
        forever #5 clk_dest = ~clk_dest;
    end

    // Stimulus
    initial begin
        // Initialize
        rst_n = 0;
        async_in = 0;

        #12;
        rst_n = 1;

        // Change async_in at random times (not aligned to clock)
        #3.5  async_in = 1;   // unaligned change
        #11  async_in = 0;
        #5.5  async_in = 1;
        #11 async_in = 0;
        /*
        #20 async_in = 1;
        #15 async_in = 0;
        #10 async_in = 1;*/
        
        #50;
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time=%0t | async_in=%b | sync_out=%b", 
                  $time, async_in, sync_out);
    end

endmodule
