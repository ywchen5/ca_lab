`timescale 1ns / 1ps

module debug_clk (
    input  wire clk,
    input  wire debug_en,
    input  wire debug_step,
    output wire debug_clk
);
  assign debug_clk = debug_en ? debug_step : clk;
endmodule
