module nearest_neighbor #(
    parameter LARGURA = 160,   // Imagem de entrada (menor)
    parameter ALTURA = 120,
    parameter MAX_FATOR = 4    // Fator máximo para dimensionar as saídas
)(
    input  wire clk,
    input  wire rst,
    input [7:0] pixel_rom,
    input sw,
    output reg [18:0] rom_addr,
    output reg [18:0] addr_ram_vga,
    output reg [7:0] pixel_saida,
    output reg done
);
    
    // Sinais para fator dinâmico e dimensões de saída
    reg [2:0] fator;
    reg [10:0] new_larg, new_altura;
    
    // Coordenadas
    reg [10:0] x_in, y_in;      // Coordenadas da imagem original (menor)
    reg [10:0] x_out, y_out;    // Coordenadas da imagem de saída (maior)
    
    // Determina o fator baseado no switch
    always @(*) begin
        if (sw) begin
            fator = 4;
            new_larg = LARGURA * 4;    // 640
            new_altura = ALTURA * 4;   // 480
        end else begin
            fator = 2;
            new_larg = LARGURA * 2;    // 320
            new_altura = ALTURA * 2;   // 240
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rom_addr     <= 0;
            addr_ram_vga <= 0;
            x_in         <= 0;
            y_in         <= 0;
            x_out        <= 0;
            y_out        <= 0;
            done         <= 0;
            pixel_saida  <= 0;
        end else if (~done) begin
            // Mapeia coordenadas de saída para coordenadas de entrada
            // (vizinho mais próximo - divisão pelo fator atual)
            if (fator == 4) begin
                x_in = x_out >> 2;  // Divide por 4
                y_in = y_out >> 2;  // Divide por 4
            end else begin
                x_in = x_out >> 1;  // Divide por 2
                y_in = y_out >> 1;  // Divide por 2
            end
            
            // Endereço da ROM (imagem menor)
            rom_addr <= y_in * LARGURA + x_in;
            
            // Pixel de saída é o mesmo da entrada (replicação)
            pixel_saida <= pixel_rom;
            
            // Endereço da RAM VGA (imagem maior)
            addr_ram_vga <= y_out * new_larg + x_out;
            
            // Avança coordenadas da imagem de saída
            if (x_out >= new_larg - 1) begin
                x_out <= 0;
                if (y_out >= new_altura - 1) begin
                    y_out <= 0;
                    done <= 1;  // terminou toda a imagem
                end else begin
                    y_out <= y_out + 1;  // próxima linha
                end
            end else begin
                x_out <= x_out + 1;  // próxima coluna
            end
        end
    end
endmodule