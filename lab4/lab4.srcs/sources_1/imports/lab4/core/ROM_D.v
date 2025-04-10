`timescale 1ns / 1ps

module ROM_D(
    input[7:0] a,
    output[31:0] spo
);

    reg[31:0] inst_data[0:255];

    initial	begin
        $readmemh("rom.mem", inst_data);
    end

    assign spo = inst_data[a];

endmodule