`timescale 1ns / 1ps

module CSRRegs (
    input wire clk,
    input wire rst,
    input wire [11:0] raddr,
    input wire [11:0] waddr,
    input wire [31:0] wdata,
    input wire csr_w,
    input wire [1:0] csr_wsc_mode,
    input wire bypass_EN,
    input wire [31:0] mepc_bypass_in,
    input wire [31:0] mcause_bypass_in,
    input wire [31:0] mtval_bypass_in,
    input wire [31:0] mstatus_bypass_in,
    output wire [31:0] rdata,
    output wire [31:0] mstatus,
    output wire [31:0] mepc,
    output wire [31:0] mtvec
);
  // You may need to modify this module, and input / output to this module
  reg [31:0] CSR[0:15];

  // Address mapping. The address is 12 bits, but only 4 bits are used in this module.
  // Maps 0x300-0x307 to CSR[0]-CSR[7], and 0x340-0x344 to CSR[8]-CSR[12]
  wire raddr_valid = raddr[11:7] == 5'h6 && raddr[5:3] == 3'h0;
  wire [3:0] raddr_map = (raddr[6] << 3) + raddr[2:0];
  wire waddr_valid = waddr[11:7] == 5'h6 && waddr[5:3] == 3'h0;
  wire [3:0] waddr_map = (waddr[6] << 3) + waddr[2:0];

  assign mstatus = CSR[0];
  assign mepc = CSR[9];
  assign mtvec = CSR[5];

  assign rdata   = CSR[raddr_map];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      CSR[0]  <= 32'h88;  // 0x300 mstatus
      CSR[1]  <= 0;  // 0x301 misa
      CSR[2]  <= 0;  // 0x302 medeleg
      CSR[3]  <= 0;  // 0x303 mideleg
      CSR[4]  <= 32'hfff;  // 0x304 mie
      CSR[5]  <= 0;  // 0x305 mtvec
      CSR[6]  <= 0;  // 0x306 mcounteren
      CSR[7]  <= 0;
      CSR[8]  <= 0;  // 0x340 mscratch
      CSR[9]  <= 0;  // 0x341 mepc
      CSR[10] <= 0;  // 0x342 mcause
      CSR[11] <= 0;  // 0x343 mtval
      CSR[12] <= 0;  // 0x344 mip
      CSR[13] <= 0;
      CSR[14] <= 0;
      CSR[15] <= 0;
    end else if (csr_w) begin
      case (csr_wsc_mode)
        2'b01:   CSR[waddr_map] = wdata;
        2'b10:   CSR[waddr_map] = CSR[waddr_map] | wdata;
        2'b11:   CSR[waddr_map] = CSR[waddr_map] & ~wdata;
        default: CSR[waddr_map] = wdata;
      endcase
    end else if (bypass_EN) begin
        CSR[0] <= mstatus_bypass_in;
        CSR[9] <= mepc_bypass_in;
        CSR[10] <= mcause_bypass_in;
        CSR[11] <= mtval_bypass_in;
    end
  end
endmodule
