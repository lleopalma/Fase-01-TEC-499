module bin_to_bcd (
    input wire [7:0] bin_in,
    output reg [3:0] bcd_centenas,
    output reg [3:0] bcd_dezenas,
    output reg [3:0] bcd_unidades
);

    always @(bin_in) begin
        // Algoritmo "Double Dabble" para conversão
        reg [11:0] bcd;
        integer i;

        bcd = 0;
        for (i = 0; i < 8; i = i + 1) begin
            // Ajuste BCD antes de deslocar
            if (i > 0 && bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;
            if (i > 0 && bcd[7:4] >= 5) bcd[7:4] = bcd[7:4] + 3;
            if (i > 0 && bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 3;

            // Desloca o próximo bit de bin_in para o registrador BCD
            bcd = {bcd[10:0], bin_in[7-i]};
        end

        bcd_centenas = bcd[11:8];
        bcd_dezenas  = bcd[7:4];
        bcd_unidades = bcd[3:0];
    end

endmodule
