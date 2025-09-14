module interpolation
(
    input wire [31:0] buffer_pixels_in_dc,  
    output wire [63:0] buffer_pixels_out_dc 
);
    wire [7:0] pixel0, pixel1, pixel2, pixel3;
    
    assign pixel0 = buffer_pixels_in_dc[31:24];
    assign pixel1 = buffer_pixels_in_dc[23:16];
    assign pixel2 = buffer_pixels_in_dc[15:8];
    assign pixel3 = buffer_pixels_in_dc[7:0];
    
    assign buffer_pixels_out_dc = {pixel0, pixel0, pixel1, pixel1, pixel2, pixel2, pixel3, pixel3};

endmodule