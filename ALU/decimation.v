module decimation #(
    parameter LARGURA = 160,
    parameter ALTURA = 120
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
    
    // Determina o fator baseado no switch
    always @(*) begin
        if (sw) begin
            fator = 4;
            new_larg = LARGURA / 4;    // 40
            new_altura = ALTURA / 4;   // 30
        end else begin
            fator = 2;
            new_larg = LARGURA / 2;    // 80
            new_altura = ALTURA / 2;   // 60
        end
    end
    
    reg [10:0] x_in, y_in;
    reg [10:0] x_out, y_out;
    
    // Estados para controle
    reg [1:0] estado_x, estado_y;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rom_addr     <= 0;
            addr_ram_vga <= 0;
            x_in         <= 0;
            y_in         <= 0;
            done         <= 0;
            pixel_saida  <= 0;
        end else if (~done) begin
            // Endereço da ROM (entrada 160x120)
            rom_addr <= y_in * LARGURA + x_in;
            
            // Mapeia para saída decimada usando valores dinâmicos
            pixel_saida   <= pixel_rom;
            addr_ram_vga  <= (y_in / fator) * new_larg + (x_in / fator);
            
            // Avança coordenadas da ROM, pulando fator em X
            if (x_in >= LARGURA - fator) begin
                x_in <= 0;
                if (y_in >= ALTURA - fator) begin
                    y_in <= 0;
                    done <= 1;  // terminou toda a imagem
                end else begin
                    y_in <= y_in + fator;  // pula linhas usando fator dinâmico
                end
            end else begin
                x_in <= x_in + fator;  // pula colunas usando fator dinâmico
            end
        end
    end
endmodule