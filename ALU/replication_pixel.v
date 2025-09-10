module replication_pixel 
(
    input  wire [31:0] buffer_pixels_in_rp,
    output wire [63:0] buffer_pixels_out_rp
);

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : replicar
            assign buffer_pixels_out_rp[(i*2 + 0)*8 +: 8] = buffer_pixels_in_rp[i*8 +: 8];
            assign buffer_pixels_out_rp[(i*2 + 1)*8 +: 8] = buffer_pixels_in_rp[i*8 +: 8];
        end
    endgenerate

endmodule