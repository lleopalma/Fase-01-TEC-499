module decimation
(
	input wire [31:0] buffer_pixels_in_dc,
   output wire [63:0] buffer_pixels_out_dc
);

	 wire [7:0] byte0, byte1;

    assign byte0 = (buffer_pixels_in_dc >> 16) & 8'b11111111;
    assign byte1 = buffer_pixels_in_dc & 8'b11111111;
	 
	 assign buffer_pixels_out_dc = {byte0,byte1};
	 
endmodule