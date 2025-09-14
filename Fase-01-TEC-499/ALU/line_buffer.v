module line_buffer (
    input clk,
    input rst,
    input [7:0] pixel,
    input pixel_valid,
    output [31:0] pixel_out,
    input rd_pixel
);
    reg [7:0] line [639:0];
    reg [8:0] wrpntr;
    reg [8:0] rdpntr;

    always @(posedge clk) begin
        if (pixel_valid)
            line[wrpntr] <= pixel;
    end

    always @(posedge clk) begin
        if (rst)
            wrpntr <= 'd0;

        else if (pixel_valid) 
            wrpntr <= wrpntr + 'd1;
    end

    assign pixel_out = [line[rdpntr], line[rdpntr + 1], line[rdpntr + 2], line[rdpntr + 3]];

    always @(posedge clk) begin
        if (rst)
            rdpntr <= 'd0;
        else if (rd_pixel)
            rdpntr <= rdpntr + 'd1;
    end
endmodule