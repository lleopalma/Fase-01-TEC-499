module control (
    input vga_reset,
    input clock,
    input [3:0] switch,
    input sw,
    output hsyncm,
    output vsyncm,
    output [7:0] redm,
    output [7:0] greenm,
    output [7:0] bluem,
    output blank,
    output sync,
    output clks
);
    wire [2:0] opcode;
    wire decoding;
	 
    decoder dec(
        .sw(switch),
        .opcode(opcode),
        .decoding(decoding)
    );
    
    wire [9:0] next_x;
    wire [9:0] next_y;
    
    // Clock VGA (25 MHz)
    reg clk_vga = 0;
    always @(posedge clock) begin
        clk_vga <= ~clk_vga;
    end
    
    // VGA driver
    vga_driver draw (
        .clock(clk_vga),
        .reset(!vga_reset),
        .color_in(color_in),
        .next_x(next_x),
        .next_y(next_y),
        .hsync(hsyncm),
        .vsync(vsyncm),
        .sync(sync),
        .clk(clks),
        .blank(blank),
        .red(redm),
        .green(greenm),
        .blue(bluem)
    );
    
    // Parâmetros da imagem ORIGINAL
    parameter IMG_W = 160;
    parameter IMG_H = 120;
    
    // Fator dinâmico baseado no sinal sw
    wire [2:0] fator;
    assign fator = sw ? 4 : 2;  // sw=1 → fator=4, sw=0 → fator=2
    
    // Cálculo dinâmico dos parâmetros ampliados baseado no seletor sw
    wire [9:0] IMG_W_AMP;
    wire [9:0] IMG_H_AMP;
    
    assign IMG_W_AMP = ((opcode == 3'b001 || opcode == 3'b011) && decoding) ? IMG_W * fator : 
                       ((opcode == 3'b010 || opcode == 3'b100) && decoding) ? IMG_W / fator : IMG_W;
    
    assign IMG_H_AMP = ((opcode == 3'b001 || opcode == 3'b011) && decoding) ? IMG_H * fator : 
                       ((opcode == 3'b010 || opcode == 3'b100) && decoding) ? IMG_H / fator : IMG_H;
    
    // Offsets para centralizar a imagem
    wire [9:0] x_offset = (640 - IMG_W_AMP)/2;
    wire [9:0] y_offset = (480 - IMG_H_AMP)/2;
    
    // Verifica se está dentro da área da imagem
    wire in_image = (next_x >= x_offset && next_x < x_offset + IMG_W_AMP) &&
                    (next_y >= y_offset && next_y < y_offset + IMG_H_AMP);
    
    // Endereço comum para RAM e ROM
    reg [18:0] addr_reg;
    reg [9:0] orig_x;
    reg [9:0] orig_y;
    
    always @(posedge clk_vga) begin
        if (in_image) begin
            if (decoding) begin
                // Para RAM: mapeia coordenadas da tela para endereços da RAM ampliada
                addr_reg <= (next_y - y_offset) * IMG_W_AMP + (next_x - x_offset);
            end else begin
                // Para ROM: mapeia para imagem original (sem ampliação)
                // Calcula posição relativa na imagem original
                orig_x <= (next_x - x_offset) * IMG_W / IMG_W_AMP;
                orig_y <= (next_y - y_offset) * IMG_H / IMG_H_AMP;
                addr_reg <= orig_y * IMG_W + orig_x;
            end
        end else begin
            addr_reg <= 0; // fora da imagem → fundo preto
        end
    end
    
    // Framebuffer RAM
    wire [7:0] ram_data;
    ram framebuffer (
        .clock(clock),
        .data(wr_data),
        .rdaddress(addr_reg),
        .wraddress(wr_addr),
        .wren(wr_en),
        .q(ram_data)
    );
    
    // ROM (imagem original)
    wire [7:0] rom_data;
    wire [18:0] rom_addr;
    ROM rom_image (
        .address(decoding ? rom_addr : addr_reg), // ROM usa addr_reg quando decoding=0
        .clock(clock),
        .q(rom_data)
    );
    
    // Copiador ROM → RAM com ampliação
    wire [18:0] wr_addr;
    wire [7:0] wr_data;
    wire wr_en;
    wire copy_done;
    
    rom_to_ram copier (
        .clk(clock),
        .reset(!vga_reset),
        .seletor(opcode),
        .decoding(decoding),
        .sw(sw),  // Passa o sinal sw para o copiador
        .rom_addr(rom_addr),
        .rom_data(rom_data),
        .ram_wraddr(wr_addr),
        .ram_data(wr_data),
        .ram_wren(wr_en),
        .done(copy_done)
    );
    
    // Multiplexador para seleção da fonte de dados
    wire [7:0] selected_data;
    assign selected_data = decoding ? ram_data : rom_data;
    
    // Atribuindo o color_in
    wire [7:0] color_in;
    assign color_in = (in_image) ? selected_data : 8'd0;
endmodule