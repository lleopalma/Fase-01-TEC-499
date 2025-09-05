module nn_zoom_out
#(
    parameter largura = 320,
    parameter altura = 240,
    parameter fator = 2
)
(
    input clk,
    input reset,
    input wire [(largura*8 - 1):0] buffer_pixel_in,
    output wire [((largura >> 1)*8 - 1):0] buffer_pixel_out
);

   localparam tamanho_linha = largura >> 1;

   genvar i;

   generate
    for (i = 0; i < tamanho_linha; i = i + 1) 
    begin : nova_linha
        assign buffer_pixel_out[(i*8)+7:i*8] = buffer_pixel_in[(i*fator*8)+7 : i*fator*8];
    end
   endgenerate
endmodule