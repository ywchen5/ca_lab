`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    21:34:44 03/12/2012
// Design Name:
// Module Name:    REGS EX/MEM Latch
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module REG_MEM_WB (
    input  wire        clk,             //MEM/WB Latch
    input  wire        rst,
    input  wire        EN,              //流水寄存器使能
    input  wire [31:0] IR_MEM,          //当前执行指令(测试)
    input  wire [31:0] PCurrent_MEM,    //当前执行指令存储器指针
    input  wire [31:0] ALUO_MEM,        //当前ALU执行输出：有效地址或ALU操作
    input  wire [31:0] Datai,           //MIOl输入CPU数据
    input  wire [ 4:0] rd_MEM,          //传递当前指令写目的寄存器地址
    input  wire        DatatoReg_MEM,   //传递当前指令REG写数据通道选择
    input  wire        RegWrite_MEM,    //传递当前指令寄存器写信号
    input  wire        flush,
    input  wire [ 3:0] exp_vector_MEM,
    output reg  [31:0] PCurrent_WB,     //锁存传递当前指令地址
    output reg  [31:0] IR_WB,           //锁存传递当前指令(测试)
    output reg  [31:0] ALUO_WB,         //锁存ALU操作结果：有效地址或ALU操作
    output reg  [31:0] MDR_WB,          //锁存MIO送CPU输入数据
    output reg  [ 4:0] rd_WB,           //锁存传递当前指令写目的寄存器地址
    output reg         DatatoReg_WB,    //锁存传递当前指令REG写数据通道选择
    output reg         RegWrite_WB,     //锁存传递当前指令寄存器写信号
    output reg         isFlushed,
    output reg  [ 3:0] exp_vector_WB
);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      rd_WB         <= 0;
      RegWrite_WB   <= 0;
      IR_WB         <= 0;
      PCurrent_WB   <= 0;
      isFlushed     <= 0;
      exp_vector_WB <= 0;
      ALUO_WB       <= 0;
      MDR_WB        <= 0;
      DatatoReg_WB  <= 0;
    end else if (EN) begin  //EX级正常传输到MEM级
      if (flush) begin
        IR_WB         <= 32'h00000013;
        PCurrent_WB   <= PCurrent_MEM;
        rd_WB         <= 0;
        RegWrite_WB   <= 0;
        isFlushed     <= 1;
        exp_vector_WB <= 0;
      end else begin
        IR_WB         <= IR_MEM;
        PCurrent_WB   <= PCurrent_MEM;  ////MEM/WB.PC
        ALUO_WB       <= ALUO_MEM;  //ALU操作结果写目的寄存器数据
        MDR_WB        <= Datai;  //存储器读出数据：写目的寄存器
        rd_WB         <= rd_MEM;  //写目的寄存器地址
        RegWrite_WB   <= RegWrite_MEM;  //寄存器写信号
        DatatoReg_WB  <= DatatoReg_MEM;  //REG写数据通道选择
        isFlushed     <= 0;
        exp_vector_WB <= exp_vector_MEM;
      end
    end
  end
endmodule
