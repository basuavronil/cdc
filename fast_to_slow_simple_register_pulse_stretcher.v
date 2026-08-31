module pulse_stretcher_simple(
  input fast_clk, slow_clk, rst, pulse_in,
  output pulse_out
);
  reg pulse_stretched, sync_ff1, sync_ff2;
  always@(posedge fast_clk or negedge rst) 
    begin
      if (!rst)
        pulse_streteched <= 1'd0;
      else 
        begin 
          if(pulse_in)
            pulse_streteched <= 1'd1;
          else 
            pulse_streteched <= 1'd0;
        end
    end
  always@(posedge slow_clk or negedge rst)
    begin
      if(!rst)
        begin
          sync_ff1 <= 1'd0;
          sync_ff2 <= 1'd0;
        end
      else 
        begin
          sync_ff1 <= pulse_stretched;
          sync_ff2 <= sync_ff1;
        end
    end
  assign pulse_out <= sync_ff2;
endmodule
    
  
