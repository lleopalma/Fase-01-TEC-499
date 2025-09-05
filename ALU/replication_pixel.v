module replication_pixel
#(
    parameter largura = 320,
    parameter altura = 240,
    parameter fator = 2
)
(
    input clk,
    input reset,
    input wire [(largura*8 - 1):0] buffer_pixel_in,
    output wire [((largura << 1)*8 - 1):0] buffer_pixel_out
);

    genvar i;
    generate
        for (i = 0; i < largura; i = i + 1) begin : replicar
            assign buffer_pixel_out[(i*fator + 0)*8 +: 8] = buffer_pixel_in[i*8 +: 8];
            assign buffer_pixel_out[(i*fator + 1)*8 +: 8] = buffer_pixel_in[i*8 +: 8];
        end
    endgenerate

endmodule
