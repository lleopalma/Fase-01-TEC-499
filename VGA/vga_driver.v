module vga_driver (
    input  wire clock,     // 25 MHz
    input  wire reset,     // ativo em nível alto

    input  wire [7:0] color_in, // cor do pixel atual (cinza ou paleta)

    output wire [9:0] next_x,   // coordenada x do próximo pixel
    output wire [9:0] next_y,   // coordenada y do próximo pixel
    output wire hsync,          // HSYNC
    output wire vsync,          // VSYNC
    output wire blank,          // BLANK
    output wire sync,           // SYNC
    output wire clk,            // CLK para VGA

    output wire [7:0] red,
    output wire [7:0] green,
    output wire [7:0] blue
);

    // parâmetros horizontais
    parameter H_ACTIVE = 640-1;
    parameter H_FRONT  = 16-1;
    parameter H_PULSE  = 96-1;
    parameter H_BACK   = 48-1;

    // parâmetros verticais
    parameter V_ACTIVE = 480-1;
    parameter V_FRONT  = 10-1;
    parameter V_PULSE  = 2-1;
    parameter V_BACK   = 33-1;

    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;
    reg hsync_reg = 1, vsync_reg = 1;

    // horizontal/vertical sync
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
            hsync_reg <= 1;
            vsync_reg <= 1;
        end else begin
            if (h_count == H_ACTIVE + H_FRONT + H_PULSE + H_BACK)
                h_count <= 0;
            else
                h_count <= h_count + 1;

            if (h_count == H_ACTIVE + H_FRONT + H_PULSE + H_BACK) begin
                if (v_count == V_ACTIVE + V_FRONT + V_PULSE + V_BACK)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end

            // HSYNC ativo baixo
            hsync_reg <= ~((h_count > H_ACTIVE + H_FRONT) &&
                           (h_count <= H_ACTIVE + H_FRONT + H_PULSE));

            // VSYNC ativo baixo
            vsync_reg <= ~((v_count > V_ACTIVE + V_FRONT) &&
                           (v_count <= V_ACTIVE + V_FRONT + V_PULSE));
        end
    end

    assign hsync   = hsync_reg;
    assign vsync   = vsync_reg;
    assign blank   = (h_count <= H_ACTIVE && v_count <= V_ACTIVE);
    assign sync    = 1'b0;
    assign clk     = clock;

    assign next_x  = (h_count <= H_ACTIVE) ? h_count : 10'd0;
    assign next_y  = (v_count <= V_ACTIVE) ? v_count : 10'd0;

    // Saída de cor (só válida na região ativa)
    // Agora, aqui a lógica verifica se está em branco e em área ativa, e coloca a cor ou preto.
    assign red   = (blank) ? color_in : 8'd0;
    assign green = (blank) ? color_in : 8'd0;
    assign blue  = (blank) ? color_in : 8'd0;

endmodule