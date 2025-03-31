`timescale 1ns / 1ps

module BHT(
    input clk,
    input rst,
    input [31:0] pc,
    input [1:0] bht_wen,
    input taken,
    output reg bht_rdata
    );

    parameter Pridict_Strongly_Taken = 2'b11;
    parameter Pridict_Weakly_Taken = 2'b10;
    parameter Pridict_Weakly_Not_Taken = 2'b01;
    parameter Pridict_Strongly_Not_Taken = 2'b00;

    // 2-bit FSM
    reg [1:0] bht [0:3]; // 4 entries for BHT
    integer i;
    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            bht[i] = Pridict_Strongly_Not_Taken; // Initialize all entries to Strongly Not Taken
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 4; i = i + 1) begin
                bht[i] <= Pridict_Strongly_Not_Taken; // Reset all entries to Strongly Not Taken
            end
        end else begin
            if (bht_wen) begin
                if (taken) begin
                    
                end
            end
        end
    end


endmodule
