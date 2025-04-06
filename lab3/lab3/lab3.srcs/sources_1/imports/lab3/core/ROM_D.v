`timescale 1ns / 1ps

module ROM_D(
    input[7:0] a,
    output[31:0] spo
);

    reg[31:0] inst_data[0:255];

    initial	begin
        $readmemh("D:\\study\\year2sem2\\ca\\ca_lab\\ca_lab\\lab3\\rom.mem", inst_data);
    end

    assign spo = inst_data[a];

endmodule