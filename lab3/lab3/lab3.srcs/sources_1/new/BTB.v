`timescale 1ns / 1ps
module BTB(
    input clk,
    input rst,
    input [31:0] PC_IF,
    input [31:0] PC_ID,
    input [31:0] PC_jump,
    input btb_wen,
    output reg hit,
    output reg [31:0] btb_rdata
    );

    parameter BTB_SIZE = 256; // Number of entries in the BTB
    parameter BTB_INDEX_WIDTH = 8; // Index width for the BTB

    reg [31:0] btb_fetch_pc [0:BTB_SIZE-1]; // BTB entries for fetched PC
    reg [31:0] btb_predict_pc [0:BTB_SIZE-1]; // BTB entries for predicted PC
    reg [BTB_INDEX_WIDTH-1:0] btb_top; // Top index for the BTB

    // reg [31:0] PC_IF_reg; // Register to hold the fetched PC
    // initial begin
    //     PC_IF_reg = 32'b0; // Initialize the PC_IF register
    // end
    // always @(posedge clk or posedge rst) begin
    //     if (rst) begin
    //         PC_IF_reg <= 32'b0; // Reset the PC_IF register
    //     end else begin
    //         PC_IF_reg <= PC_IF; // Update the PC_IF register
    //     end
    // end


    integer i;
    initial begin
        for (i = 0; i < BTB_SIZE; i = i + 1) begin
            btb_fetch_pc[i] = -1; // Initialize all entries to -1
            btb_predict_pc[i] = -1; // Initialize all entries to -1
        end
        btb_top <= 0; // Initialize top bit to 0
    end

    integer j;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < BTB_SIZE; i = i + 1) begin
                btb_fetch_pc[i] <= -1; // Reset all entries to -1
                btb_predict_pc[i] <= -1; // Reset all entries to -1
                btb_top <= 0; // Reset top index to 0
            end
        end else begin
            if (btb_wen) begin
                j = 0; // Initialize j to 0
                for (i = 0; i < btb_top; i = i + 1) begin
                    if (btb_fetch_pc[i] == PC_ID) begin
                        btb_predict_pc[i] <= PC_jump; // Update the predicted PC if a match is found
                        j = 1; // Set j to 1 to indicate a match
                    end
                end
                if (j == 0) begin
                    if (btb_top < BTB_SIZE) begin
                        btb_fetch_pc[btb_top] <= PC_ID; // Add new entry to the BTB
                        btb_predict_pc[btb_top] <= PC_jump; // Set the predicted PC for the new entry
                        btb_top <= btb_top + 1; // Increment the top index
                    end
                end
            end
        end
    end

    always @* begin 
        hit = 1'b0; // Initialize hit flag to 0
        for (i = 0; i < BTB_SIZE; i = i + 1) begin
            if (btb_fetch_pc[i] == PC_IF) begin
                btb_rdata = btb_predict_pc[i]; // Output the predicted PC if a match is found
                hit = 1'b1; // Set hit flag to 1
            end
        end
        if (hit == 1'b0) begin
            btb_rdata = 32'b0; // If no match, output 0
        end
    end


endmodule