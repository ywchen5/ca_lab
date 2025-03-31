`timescale 1ps/1ps

module HazardDetectionUnit(
    input clk,
    input Branch_ID, rs1use_ID, rs2use_ID,
    input[1:0] hazard_optype_ID,
    input[4:0] rd_EXE, rd_MEM, rs1_ID, rs2_ID, rs2_EXE,
    output PC_EN_IF, reg_FD_EN, reg_FD_stall, reg_FD_flush,
        reg_DE_EN, reg_DE_flush, reg_EM_EN, reg_EM_flush, reg_MW_EN,
    output forward_ctrl_ls,
    output[1:0] forward_ctrl_A, forward_ctrl_B
);
    //according to the diagram, design the Hazard Detection Unit
    reg [1:0] hazard_optype_EXE, hazard_optype_MEM;

    initial begin
        hazard_optype_EXE = 2'b00;
        hazard_optype_MEM = 2'b00;
    end

    always @(posedge clk) begin
        hazard_optype_EXE <= hazard_optype_ID;
        hazard_optype_MEM <= hazard_optype_EXE;
    end

    wire load_use_hazard = hazard_optype_EXE == 2'b01 && (rd_EXE == rs1_ID || rd_EXE == rs2_ID) && rd_EXE != 5'b0 && hazard_optype_ID != 2'b10 ? 1'b1 : 1'b0;
    wire branch_hazard = hazard_optype_ID == 2'b11 ? 1'b1 : 1'b0;


    assign forward_ctrl_A = rs1use_ID ? rd_EXE == rs1_ID && rd_EXE != 5'b0 ? 2'b01 :
                                        rd_MEM == rs1_ID && rd_MEM != 5'b0 ? hazard_optype_MEM == 2'b01 ? 2'b11 :
                                                                                        2'b10 : 
                                                           2'b00 : 
                                        2'b00;
    assign forward_ctrl_B = rs2use_ID ? rd_EXE == rs2_ID && rd_EXE != 5'b0 ? 2'b01 :
                                        rd_MEM == rs2_ID && rd_MEM != 5'b0 ? hazard_optype_MEM == 2'b01 ? 2'b11 :
                                                                                        2'b10 : 
                                                           2'b00 : 
                                        2'b00;

    assign forward_ctrl_ls = hazard_optype_EXE == 2'b10 && hazard_optype_MEM == 2'b01 && rd_MEM == rs2_EXE && rd_MEM != 5'b0 ? 1'b1 : 1'b0;

    assign PC_EN_IF = load_use_hazard ? 1'b0 : 1'b1;
    assign reg_FD_stall = load_use_hazard ? 1'b1 : 1'b0;
    assign reg_FD_flush = branch_hazard ? 1'b1 : 1'b0;
    assign reg_DE_flush = load_use_hazard ? 1'b1 : 1'b0;                                                      

    assign reg_EM_flush = 1'b0;
    assign reg_FD_EN = 1'b1;
    assign reg_DE_EN = 1'b1;
    assign reg_EM_EN = 1'b1;
    assign reg_MW_EN = 1'b1;


endmodule