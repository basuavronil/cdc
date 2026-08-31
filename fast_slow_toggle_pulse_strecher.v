module abc(
  input wire fast_clk,
  input wire slow_clk,
  input wire rst,
  input wire pulse_in,
  output wire pulse_out
);

  reg [3:0] counter;
  reg p_stretcher;
  reg sync_ff1, sync_ff2;

  // Pulse Stretcher on fast_clk
  always @(posedge fast_clk or negedge rst) begin
    if (!rst) begin
      counter     <= 4'd0;
      p_stretcher <= 1'b0;
    end else begin
      if (pulse_in) begin
        counter     <= 4'd10;
        p_stretcher <= 1'b1; // Output high immediately on trigger
      end else if (counter != 4'd0) begin
        counter     <= counter - 1'b1;
        p_stretcher <= 1'b1;
      end else begin
        p_stretcher <= 1'b0;
      end
    end
  end

  // 2-Flip-Flop Synchronizer on slow_clk
  always @(posedge slow_clk or negedge rst) begin
    if (!rst) begin
      sync_ff1 <= 1'b0;
      sync_ff2 <= 1'b0;
    end else begin
      sync_ff1 <= p_stretcher;
      sync_ff2 <= sync_ff1;
    end
  end

  assign pulse_out = sync_ff2;

endmodule
