module vga_top (
    input reset,
    input clock,
    output [9:0] next_x,
    output [9:0] next_y,
    output VGA_HS,
    output VGA_VS,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_BLANK_N,
    output VGA_SYNC_N,
    output VGA_CLK
);

    // Clock VGA (25 MHz)
    reg clk_vga = 0;
    always @(posedge clock) begin
        clk_vga <= ~clk_vga;
    end

    // VGA driver
    vga_driver draw (
        .clock(clk_vga),
        .reset(reset),
        .color_in(8'd0), // Temporariamente preto
        .next_x(next_x),
        .next_y(next_y),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .blank(VGA_BLANK_N),
        .sync(VGA_SYNC_N),
        .clk(VGA_CLK),
        .red(VGA_R),
        .green(VGA_G),
        .blue(VGA_B)
    );

    // parâmetros da imagem
    parameter IMG_W = 160;
    parameter IMG_H = 120;

    // offsets para centralizar
    wire [9:0] x_offset = (640 - IMG_W)/2; // 240
    wire [9:0] y_offset = (480 - IMG_H)/2; // 180

    // verifica se está dentro da área da imagem
    wire in_image = (next_x >= x_offset && next_x < x_offset + IMG_W) &&
                    (next_y >= y_offset && next_y < y_offset + IMG_H);

    // endereço da RAM
    reg [18:0] addr_reg;
    always @(posedge clk_vga) begin
        if (in_image)
            addr_reg <= (next_y - y_offset) * IMG_W + (next_x - x_offset);
        else
            addr_reg <= 0; // fora da imagem → fundo preto
    end

    // framebuffer RAM
    wire [7:0] c;
    RAM framebuffer (
        .clock(clk_vga),
        .data(wr_data),
        .rdaddress(addr_reg),
        .wraddress(wr_addr),
        .wren(wr_en),
        .q(c)
    );

    // saída VGA
    assign VGA_R   = (VGA_BLANK_N && in_image) ? c : 8'd0;
    assign VGA_G = (VGA_BLANK_N && in_image) ? c : 8'd0;
    assign VGA_B  = (VGA_BLANK_N && in_image) ? c : 8'd0;

    // ROM (imagem original)
    wire [7:0] rom_pixel;
    wire [18:0] rom_addr;

    lena rom_image (
        .address(rom_addr),
        .clock(clk_vga),
        .q(rom_pixel)
    );

    // copiador ROM → RAM
    wire [18:0] wr_addr;
    wire [7:0] wr_data;
    wire wr_en;

    rom_to_ram copier (
        .clk(clk_vga),
        .reset(reset),
        .rom_addr(rom_addr),
        .rom_data(rom_pixel),
        .ram_wraddr(wr_addr),
        .ram_data(wr_data),
        .ram_wren(wr_en),
        .done()
    );

endmodule