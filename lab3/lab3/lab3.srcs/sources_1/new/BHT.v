`timescale 1ns / 1ps

module BHT(
    input clk,
    input rst,
    input [31:0] PC_IF,
    input bht_wen,
    input taken,
    output wire bht_pridict
    );

    parameter Pridict_Strongly_Taken = 2'b11;
    parameter Pridict_Weakly_Taken = 2'b10;
    parameter Pridict_Weakly_Not_Taken = 2'b01;
    parameter Pridict_Strongly_Not_Taken = 2'b00;

    parameter BHT_SIZE = 256; // Number of entries in the BHT

    reg [31:0] PC_IF_reg;
    initial begin
        PC_IF_reg = 32'b0; // Initialize the PC_IF register
    end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC_IF_reg <= 32'b0; // Reset the PC_IF register
        end else begin
            PC_IF_reg <= PC_IF; // Update the PC_IF register
        end
    end


    // 2-bit FSM
    reg [1:0] bht [0:BHT_SIZE - 1]; // 255 entries for 2-bit FSM  
    integer i;
    initial begin
        for (i = 0; i < BHT_SIZE; i = i + 1) begin
            bht[i] = Pridict_Weakly_Not_Taken; // Initialize all entries to Weakly Not Taken
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < BHT_SIZE; i = i + 1) begin
                bht[i] <= Pridict_Weakly_Not_Taken; // Reset all entries to Weakly Not Taken
            end
        end else begin
            if (bht_wen) begin
                if (taken) begin
                    bht[PC_IF_reg[9:2]] <= (bht[PC_IF_reg[9:2]] == Pridict_Strongly_Taken) ? Pridict_Strongly_Taken : bht[PC_IF_reg[9:2]] + 1; // Increment if taken
                end else begin
                    bht[PC_IF_reg[9:2]] <= (bht[PC_IF_reg[9:2]] == Pridict_Strongly_Not_Taken) ? Pridict_Strongly_Not_Taken : bht[PC_IF_reg[9:2]] - 1; // Decrement if not taken
                end
            end
        end
    end

    assign bht_pridict = bht[PC_IF[9:2]] >= Pridict_Weakly_Taken;

endmodule
