// BAD: Diverging the signal before synchronization
module cdc_divergence_bad (
    input clk_dest,
    input rst_n,
    input en_src,      // Signal from asynchronous source domain
    output reg out_v1, // Branch 1
    output reg out_v2  // Branch 2
);

    // Synchronizer Chain 1
    reg sync1_stage1, sync1_stage2;
    always @(posedge clk_dest or negedge rst_n) begin
        if (!rst_n) begin
            sync1_stage1 <= 1'b0;
            sync1_stage2 <= 1'b0;
        end else begin
            sync1_stage1 <= en_src;
            sync1_stage2 <= sync1_stage1;
        end
    end

    // Synchronizer Chain 2 (The Divergence)
    reg sync2_stage1, sync2_stage2;
    always @(posedge clk_dest or negedge rst_n) begin
        if (!rst_n) begin
            sync2_stage1 <= 1'b0;
            sync2_stage2 <= 1'b0;
        end else begin
            sync2_stage1 <= en_src;
            sync2_stage2 <= sync2_stage1;
        end
    end

    always @(posedge clk_dest) begin
        out_v1 <= sync1_stage2;
        out_v2 <= sync2_stage2;
    end

endmodule
