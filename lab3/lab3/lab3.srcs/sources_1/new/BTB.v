`timescale 1ns / 1ps
module BTB(
    input clk,
    input rst,
    input [31:0] pc,
    input [31:0] pc_jump,
    input btb_wen,
    output hit,
    output btb_rdata
    );

    parameter BTB_SIZE = 256; // Number of entries in the BTB
    parameter BTB_INDEX_WIDTH = 8; // Number of bits for the index

    reg [31:0] btb_fetch_pc [0:BTB_SIZE-1]; // BTB entries for fetched PC
    reg [31:0] btb_pridict_pc [0:BTB_SIZE-1]; // BTB entries for predicted PC
    reg [BTB_INDEX_WIDTH-1:0] btb_top; // Top index for the BTB

    initial begin
        integer i;
        for (i = 0; i < BTB_SIZE; i = i + 1) begin
            btb_fetch_pc[i] = 32'b0; // Initialize all entries to 0
            btb_pridict_pc[i] = 32'b0; // Initialize all entries to 0
        end
        btb_top <= 0; // Initialize top bit to 0
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            integer i;
            for (i = 0; i < BTB_SIZE; i = i + 1) begin
                btb_fetch_pc[i] <= 32'b0; // Reset all entries to 0
                btb_pridict_pc[i] <= 32'b0; // Reset all entries to 0
            end
        end else begin
            
            if (btb_wen) begin
                btb_fetch_pc[btb_top] <= pc; // Store the fetched PC in the BTB
                btb_pridict_pc[btb_top] <= pc_jump; // Store the predicted PC in the BTB
                btb_top <= btb_top + 1; // Increment the top index for the next entry
            end
        end
    end

    always @* begin 
        if (btb_ren) begin
            for (i = 0; i < BTB_SIZE; i = i + 1) begin
                if (btb_fetch_pc[i] == pc) begin
                    btb_rdata = btb_pridict_pc[i]; // Output the predicted PC if a match is found
                    hit = 1'b1; // Set hit flag to 1
                end
            end
            if (hit == 1'b0) begin
                btb_rdata = 32'b0; // If no match, output 0
            end
        end
    end


endmodule