`timescale 1ns / 1ps

module RAM_B (
    input  wire [31:0] addra,
    input  wire        clka,            // normal clock
    input  wire [31:0] dina,
    input  wire        wea,
    input  wire        rea,
    output wire [31:0] douta,
    input  wire [ 2:0] mem_u_b_h_w,
    output wire        l_access_fault,
    output wire        s_access_fault
);

  (* ram_style = "block" *) reg [7:0] data[0:127];

  initial begin
    $readmemh("D:\\study\\year2sem2\\ca\\ca_lab\\lab2\\ram.mem", data);
  end

  always @(negedge clka) begin
    if (wea & ~|addra[31:7]) begin
      data[addra[6:0]] <= dina[7:0];
      if (mem_u_b_h_w[0] | mem_u_b_h_w[1]) data[addra[6:0]+1] <= dina[15:8];
      if (mem_u_b_h_w[1]) begin
        data[addra[6:0]+2] <= dina[23:16];
        data[addra[6:0]+3] <= dina[31:24];
      end
    end
  end

  assign douta = addra[31:7] ? 32'b0 :
        mem_u_b_h_w[1] ? {data[addra[6:0] + 3], data[addra[6:0] + 2],
                    data[addra[6:0] + 1], data[addra[6:0]]} :
        mem_u_b_h_w[0] ? {mem_u_b_h_w[2] ? 16'b0 : {16{data[addra[6:0] + 1][7]}},
                    data[addra[6:0] + 1], data[addra[6:0]]} :
        {mem_u_b_h_w[2] ? 24'b0 : {24{data[addra[6:0]][7]}}, data[addra[6:0]]};

  assign l_access_fault = rea & |addra[31:7];
  assign s_access_fault = wea & |addra[31:7];

endmodule
