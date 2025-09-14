// ======================================================
// MÓDULO MAIN
// ======================================================
module control (
    input  vga_reset,
    input  clock,
    input  switch,       // 0 = original 160x120, 1 = ampliado 320x240
    output hsyncm,
    output vsyncm,
    output [7:0] redm,
    output [7:0] greenm,
    output [7:0] bluem,
    output blank,
    output sync,
    output clks
);
    wire [9:0] x,
    wire [9:0] y,

    // =========================
    // CLOCK VGA 25 MHz
    // =========================
    reg clk_vga = 0;
    always @(posedge clock) clk_vga <= ~clk_vga;

    // =========================
    // PARÂMETROS IMAGEM
    // =========================
    parameter IMG_W     = 160;
    parameter IMG_H     = 120;
    parameter FATOR     = 2;
    parameter IMG_W_AMP = IMG_W * FATOR; // 320
    parameter IMG_H_AMP = IMG_H * FATOR; // 240

    wire [9:0] img_w = (switch) ? IMG_W_AMP : IMG_W;
    wire [9:0] img_h = (switch) ? IMG_H_AMP : IMG_H;
    wire [9:0] x_offset = (640 - img_w)/2;
    wire [9:0] y_offset = (480 - img_h)/2;

    // =========================
    // SINAIS VGA
    // =========================
    wire [9:0] nx, ny;
    wire hsync, vsync, vblank;

    // VGA driver
    vga_driver draw (
        .clock(clk_vga),
        .reset(vga_reset),
        .color_in(8'd0), // cor temporária, será sobrescrita pelo framebuffer
        .x(nx),
        .y(ny),
        .hsync(hsync),
        .vsync(vsync),
        .sync(sync),
        .clk(clks),
        .blank(vblank),
        .red(),
        .green(),
        .blue()
    );

    assign x = nx;
    assign y = ny;
    assign hsyncm  = hsync;
    assign vsyncm  = vsync;
    assign blank   = vblank;

    // =========================
    // ENDEREÇO DA RAM PARA LEITURA
    // =========================
    reg [18:0] addr_reg;
    wire in_image = (nx >= x_offset && nx < x_offset + img_w) &&
                    (ny >= y_offset && ny < y_offset + img_h);

    always @(posedge clk_vga) begin
        if (in_image) begin
            addr_reg <= (ny - y_offset) * img_w + (nx - x_offset);
        end else begin
            addr_reg <= 0;
        end
    end

    // =========================
    // FRAMEBUFFER RAM
    // =========================
    wire [7:0] c;
    wire [18:0] wr_addr;
    wire [7:0]  wr_data;
    wire wr_en;

    ram2port framebuffer (
        .clock(clk_vga),
        .data(wr_data),
        .rdaddress(addr_reg),
        .wraddress(wr_addr),
        .wren(wr_en),
        .q(c)
    );

    // =========================
    // ROM (IMAGEM ORIGINAL)
    // =========================
    wire [7:0] rom_pixel;
    wire [18:0] rom_addr;

    rom rom_image (
        .address(rom_addr),
        .clock(clk_vga),
        .q(rom_pixel)
    );

    // =========================
    // COPIADOR ROM → RAM COM AMPLIAÇÃO
    // =========================
    wire copy_done;

    rom_to_ram copier (
        .clk(clk_vga),
        .reset(vga_reset),
        .switch(switch),
        .rom_addr(rom_addr),
        .rom_data(rom_pixel),
        .ram_wraddr(wr_addr),
        .ram_data(wr_data),
        .ram_wren(wr_en),
        .done(copy_done)
    );

    // =========================
    // COLOR IN
    // =========================
    wire [7:0] color_in = (in_image) ? c : 8'd0;

    assign redm   = color_in;
    assign greenm = color_in;
    assign bluem  = color_in;

endmodule