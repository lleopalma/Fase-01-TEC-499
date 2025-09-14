module block_averaging
(
    input wire [31:0] buffer_pixels_in_ba,
    output wire [63:0] buffer_pixels_out_ba
);

    wire [7:0] byte0, byte1, byte2, byte3;

    assign byte0 = (buffer_pixels_in_ba >> 24) & 8'b11111111;
    assign byte1 = (buffer_pixels_in_ba >> 16) & 8'b11111111;
    assign byte2 = (buffer_pixels_in_ba >> 8)  & 8'b11111111;
    assign byte3 = buffer_pixels_in_ba & 8'b11111111;

    assign buffer_pixels_out_ba = (byte0 + byte1 + byte2 + byte3) >> 2;

endmodule