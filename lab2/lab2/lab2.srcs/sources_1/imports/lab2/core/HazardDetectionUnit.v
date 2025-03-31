`timescale 1ps / 1ps

module HazardDetectionUnit (
    input wire clk,
    input wire Branch_ID,
    input wire rs1use_ID,
    input wire rs2use_ID,
    input wire [1:0] hazard_optype_ID,
    input wire [4:0] rd_EXE,
    input wire [4:0] rd_MEM,
    input wire [4:0] rs1_ID,
    input wire [4:0] rs2_ID,
    input wire [4:0] rs2_EXE,
    output wire PC_EN_IF,
    output wire reg_FD_stall,
    output wire reg_FD_flush,
    output wire reg_DE_flush,
    output wire forward_ctrl_ls,
    output wire [1:0] forward_ctrl_A,
    output wire [1:0] forward_ctrl_B
);
  reg [1:0] hazard_optype_EXE, hazard_optype_MEM;
  always @(posedge clk) begin
    hazard_optype_MEM <= hazard_optype_EXE;
    hazard_optype_EXE <= hazard_optype_ID & {2{~reg_DE_flush}};
  end

  localparam hazard_optype_ALU = 2'd1;
  localparam hazard_optype_LOAD = 2'd2;
  localparam hazard_optype_STORE = 2'd3;

  wire rs1_forward_1     = rs1use_ID && rs1_ID == rd_EXE && (rd_EXE != 0) && hazard_optype_EXE == hazard_optype_ALU;
  wire rs1_forward_stall = rs1use_ID && rs1_ID == rd_EXE && (rd_EXE != 0) && hazard_optype_EXE == hazard_optype_LOAD
                             && hazard_optype_ID != hazard_optype_STORE;
  wire rs1_forward_2     = rs1use_ID && rs1_ID == rd_MEM && (rd_MEM != 0) && hazard_optype_MEM == hazard_optype_ALU;
  wire rs1_forward_3     = rs1use_ID && rs1_ID == rd_MEM && (rd_MEM != 0) && hazard_optype_MEM == hazard_optype_LOAD;

  wire rs2_forward_1     = rs2use_ID && rs2_ID == rd_EXE && (rd_EXE != 0) && hazard_optype_EXE == hazard_optype_ALU;
  wire rs2_forward_stall = rs2use_ID && rs2_ID == rd_EXE && (rd_EXE != 0) && hazard_optype_EXE == hazard_optype_LOAD
                             && hazard_optype_ID != hazard_optype_STORE;
  wire rs2_forward_2     = rs2use_ID && rs2_ID == rd_MEM && (rd_MEM != 0) && hazard_optype_MEM == hazard_optype_ALU;
  wire rs2_forward_3     = rs2use_ID && rs2_ID == rd_MEM && (rd_MEM != 0) && hazard_optype_MEM == hazard_optype_LOAD;

  wire load_stall = rs1_forward_stall | rs2_forward_stall;

  assign PC_EN_IF = ~load_stall;
  assign reg_FD_stall = load_stall;
  assign reg_FD_flush = Branch_ID;
  assign reg_DE_flush = load_stall;

  assign forward_ctrl_A = rs1_forward_1 ? 2'd1 : rs1_forward_2 ? 2'd2 : rs1_forward_3 ? 2'd3 : 2'b0;
  assign forward_ctrl_B = rs2_forward_1 ? 2'd1 : rs2_forward_2 ? 2'd2 : rs2_forward_3 ? 2'd3 : 2'b0;

  assign forward_ctrl_ls = rs2_EXE == rd_MEM && hazard_optype_EXE == hazard_optype_STORE
                            && hazard_optype_MEM == hazard_optype_LOAD;
endmodule
