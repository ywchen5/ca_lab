`timescale 1ns / 1ps

module BHT(
    input clk,
    input rst,
    input [31:0] pc,
    input bht_wen,
    input taken,
    output wire bht_rdata
    );

    parameter Pridict_Strongly_Taken = 2'b11;
    parameter Pridict_Weakly_Taken = 2'b10;
    parameter Pridict_Weakly_Not_Taken = 2'b01;
    parameter Pridict_Strongly_Not_Taken = 2'b00;

    // 2-bit FSM
    reg [1:0] bht [0:8]; // 9 entries for 2-bit FSM  
    integer i;
    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            bht[i] = Pridict_Strongly_Not_Taken; // Initialize all entries to Strongly Not Taken
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1) begin
                bht[i] <= Pridict_Strongly_Not_Taken; // Reset all entries to Strongly Not Taken
            end
        end else begin
            if (bht_wen) begin
                if (taken) begin
                    bht[pc[8:0]] <= (bht[pc[8:0]] == Pridict_Strongly_Taken) ? Pridict_Strongly_Taken : bht[pc[8:0]] + 1; // Increment if taken
                end else begin
                    bht[pc[8:0]] <= (bht[pc[8:0]] == Pridict_Strongly_Not_Taken) ? Pridict_Strongly_Not_Taken : bht[pc[8:0]] - 1; // Decrement if not taken
                end
            end
        end
    end

    assign bht_rdata = bht[pc[8:0]] >= Pridict_Weakly_Taken;

endmodule
