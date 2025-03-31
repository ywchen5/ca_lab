`timescale 1ns / 1ps

module ExceptionUnit (
    input wire clk,
    input wire rst,
    input wire csr_rw_in,
    // write/set/clear (funct bits from instruction)
    input wire [1:0] csr_wsc_mode_in,
    input wire csr_w_imm_mux,
    input wire [11:0] csr_rw_addr_in,
    input wire [31:0] csr_w_data_reg,
    input wire [4:0] csr_w_data_imm,
    output wire [31:0] csr_r_data_out,

    input wire interrupt,
    input wire illegal_inst,
    input wire l_access_fault,
    input wire s_access_fault,
    input wire ecall_m,

    input wire mret,

    input wire [31:0] epc_cur,
    input wire [31:0] epc_next,
    output wire [31:0] PC_redirect,
    output wire redirect_mux,
    input wire [31:0] einst,
    input wire [31:0] eaddr,

    output wire reg_FD_flush,
    output wire reg_DE_flush,
    output wire reg_EM_flush,
    output wire reg_MW_flush,
    output wire RegWrite_cancel,
    output wire MemWrite_cancel
);
  // According to the diagram, design the Exception Unit
  // You can modify any code in this file if needed!

  // mcause exception code
  parameter [31:0] MCAUSE_ILLEGAL_INST = 32'd2;
  parameter [31:0] MCAUSE_L_ACCESS_FAULT = 32'd5;
  parameter [31:0] MCAUSE_S_ACCESS_FAULT = 32'd7;
  parameter [31:0] MCAUSE_ECALL_M = 32'd11;

  // mcause interruption code
  parameter [31:0] MCAUSE_SOFT_INT = 32'h80000003;
  parameter [31:0] MCAUSE_MACHINE_EXT_INT = 32'h8000000B;

  // CSR register addresses - mapped
  parameter [11:0] CSR_MSTATUS = 12'h300;
  parameter [11:0] CSR_MTVEC = 12'h305;
  parameter [11:0] CSR_MEPC = 12'h341;
  parameter [11:0] CSR_MCAUSE = 12'h342;
  parameter [11:0] CSR_MTVAL = 12'h343;

  wire [11:0] csr_waddr;
  wire [31:0] csr_wdata;
  wire csr_w;
  wire [1:0] csr_wsc;
  wire [11:0] csr_raddr;

  wire [31:0] mstatus;
  wire [31:0] csr_rdata;
  wire [31:0] mepc;
  wire [31:0] mtvec;

  reg bypass_EN;
  reg [31:0] mepc_bypass_in, mcause_bypass_in, mtval_bypass_in, mstatus_bypass_in;

  assign csr_raddr = csr_rw_addr_in;
  assign csr_r_data_out = csr_rdata;

  reg in_trap;
  initial begin
    in_trap <= 0;
  end
  assign PC_redirect = (illegal_inst || l_access_fault || s_access_fault || ecall_m || interrupt && !in_trap) ? mtvec :
                       (mret) ? mepc : 32'h0;
  assign redirect_mux = (illegal_inst || l_access_fault || s_access_fault || ecall_m || (interrupt && !in_trap) || mret) ? 1'b1 : 1'b0;
  assign reg_FD_flush = (illegal_inst || l_access_fault || s_access_fault || ecall_m || (interrupt && !in_trap) || mret) ? 1'b1 : 1'b0;
  assign reg_DE_flush = (illegal_inst || l_access_fault || s_access_fault || ecall_m || (interrupt && !in_trap) || mret) ? 1'b1 : 1'b0;
  assign reg_EM_flush = (illegal_inst || l_access_fault || s_access_fault || ecall_m || (interrupt && !in_trap) || mret) ? 1'b1 : 1'b0;
  assign reg_MW_flush = (illegal_inst || l_access_fault || s_access_fault || ecall_m || (interrupt && !in_trap) || mret) ? 1'b1 : 1'b0;
  assign RegWrite_cancel = (illegal_inst || l_access_fault || s_access_fault || ecall_m || mret) ? 1'b1 : 1'b0;
  assign MemWrite_cancel = (illegal_inst || l_access_fault || s_access_fault || ecall_m || (interrupt && !in_trap) || mret) ? 1'b1 : 1'b0;

  assign csr_waddr = csr_rw_addr_in;
  assign csr_wdata = csr_w_imm_mux ? csr_w_data_imm : csr_w_data_reg;
  assign csr_w = csr_rw_in;
  assign csr_wsc = csr_wsc_mode_in;

  always @(posedge clk) begin
    if (rst) begin
      bypass_EN <= 0;
      mepc_bypass_in <= 0;
      mcause_bypass_in <= 0;
      mtval_bypass_in <= 0;
      mstatus_bypass_in <= 0;
      in_trap <= 0;
    end else begin
      bypass_EN <= 0;
      mepc_bypass_in <= 0;
      mcause_bypass_in <= 0;
      mtval_bypass_in <= 0;
      mstatus_bypass_in <= 0;

      if (illegal_inst) begin
        bypass_EN <= 1;
        mcause_bypass_in <= MCAUSE_ILLEGAL_INST;
        mepc_bypass_in <= epc_cur;
        mtval_bypass_in <= einst;
        mstatus_bypass_in <= {mstatus[31:13], 2'b11, mstatus[10:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]};
        in_trap <= 1;
      end else if (l_access_fault) begin
        bypass_EN <= 1;
        mcause_bypass_in <= MCAUSE_L_ACCESS_FAULT;
        mepc_bypass_in <= epc_cur;
        mtval_bypass_in <= eaddr;
        mstatus_bypass_in <= {mstatus[31:13], 2'b11, mstatus[10:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]};
        in_trap <= 1;
      end else if (s_access_fault) begin
        bypass_EN <= 1;
        mcause_bypass_in <= MCAUSE_S_ACCESS_FAULT;
        mepc_bypass_in <= epc_cur;
        mtval_bypass_in <= eaddr;
        mstatus_bypass_in <= {mstatus[31:13], 2'b11, mstatus[10:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]};
        in_trap <= 1;
      end else if (ecall_m) begin
        bypass_EN <= 1;
        mcause_bypass_in <= MCAUSE_ECALL_M;
        mepc_bypass_in <= epc_cur;
        mtval_bypass_in <= 32'h0;
        mstatus_bypass_in <= {mstatus[31:13], 2'b11, mstatus[10:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]};
        in_trap <= 1;
      end else if (interrupt && !in_trap) begin
        bypass_EN <= 1;
        mcause_bypass_in <= MCAUSE_MACHINE_EXT_INT;
        mepc_bypass_in <= epc_next;
        mtval_bypass_in <= 32'h0;
        mstatus_bypass_in <= {mstatus[31:13], 2'b11, mstatus[10:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]};
        in_trap <= 1;
      end else if (mret) begin
        in_trap <= 0;
      end
    end
  end


  CSRRegs csr (
      .clk(clk),
      .rst(rst),
      .csr_w(csr_w),
      .raddr(csr_raddr),
      .waddr(csr_waddr),
      .wdata(csr_wdata),
      .rdata(csr_rdata),
      .mstatus(mstatus),
      .csr_wsc_mode(csr_wsc),
      .bypass_EN(bypass_EN),
      .mepc_bypass_in(mepc_bypass_in),
      .mcause_bypass_in(mcause_bypass_in),
      .mtval_bypass_in(mtval_bypass_in),
      .mstatus_bypass_in(mstatus_bypass_in),
      .mepc(mepc),
      .mtvec(mtvec)
  );
endmodule
