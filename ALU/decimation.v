module decimation(
    input clk,
    input rst,
	input [2:0] fator,
    input [7:0] pixel_rom,
    output reg [18:0] rom_addr,
    output reg [18:0] addr_ram_vga,
    output reg [7:0] pixel_saida,
    output reg done
);

	parameter LARGURA = 160;
    parameter ALTURA = 120;
    wire [11:0] NEW_LARG = LARGURA / fator;
    wire [11:0] NEW_ALTURA = ALTURA / fator;

    reg [10:0] x_in, y_in;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            rom_addr <= 0;
            addr_ram_vga <= 0;
            x_in <= 0;
            y_in <= 0;
            done <= 0;
            pixel_saida <= 0;
        end else if (~done) begin
            // Endereço da ROM (entrada 160x120)
            rom_addr <= y_in * LARGURA + x_in;

            // Mapeia para saída decimada (80x60)
            pixel_saida <= pixel_rom;
            addr_ram_vga <= (y_in / fator) * NEW_LARG + (x_in / fator);

            // Avança coordenadas da ROM, pulando FATOR em X
            if (x_in >= LARGURA - fator) begin
                x_in <= 0;
                if (y_in >= ALTURA - fator) begin
                    y_in <= 0;
                    done <= 1;
                end else begin
                    y_in <= y_in + fator;
                end
            end else begin
                x_in <= x_in + fator;
            end
        end
    end
endmodule