module media #(
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
    reg [4:0] fator_quadrado;  // Para armazenar FATOR²
    
    // Determina o fator baseado no switch
    always @(*) begin
        if (sw) begin
            fator = 4;
            new_larg = LARGURA / 4;    // 40
            new_altura = ALTURA / 4;   // 30
            fator_quadrado = 16;       // 4²
        end else begin
            fator = 2;
            new_larg = LARGURA / 2;    // 80
            new_altura = ALTURA / 2;   // 60
            fator_quadrado = 4;        // 2²
        end
    end
    
    // Coordenadas do bloco atual na imagem de saída
    reg [10:0] bloco_x, bloco_y;
    
    // Coordenadas dentro do bloco atual (0 a FATOR-1)
    reg [3:0] sub_x, sub_y;
    
    // Acumulador para somar pixels do bloco
    reg [15:0] soma_pixels;  // 16 bits para suportar soma de até 16 pixels de 8 bits
    
    // Contador de pixels processados no bloco atual
    reg [4:0] pixel_count;  // 5 bits para suportar até 16 pixels
    
    // Estados da máquina de estados
    reg [1:0] estado;
    localparam IDLE = 2'b00;
    localparam READ_BLOCK = 2'b01;
    localparam CALC_AVERAGE = 2'b10;
    localparam WRITE_OUTPUT = 2'b11;
    
    // Registrador para armazenar o dado da ROM com delay
    reg [7:0] pixel_rom_reg;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rom_addr     <= 0;
            addr_ram_vga <= 0;
            bloco_x      <= 0;
            bloco_y      <= 0;
            sub_x        <= 0;
            sub_y        <= 0;
            soma_pixels  <= 0;
            pixel_count  <= 0;
            done         <= 0;
            pixel_saida  <= 0;
            estado       <= IDLE;
            pixel_rom_reg <= 0;
        end else if (~done) begin
            // Registra o dado da ROM com 1 ciclo de atraso
            pixel_rom_reg <= pixel_rom;
            
            case (estado)
                IDLE: begin
                    // Inicia processamento do primeiro bloco
                    estado <= READ_BLOCK;
                    soma_pixels <= 0;
                    pixel_count <= 0;
                    sub_x <= 0;
                    sub_y <= 0;
                end
                
                READ_BLOCK: begin
                    // Calcula endereço da ROM para o pixel atual do bloco
                    rom_addr <= (bloco_y * fator + sub_y) * LARGURA + 
                               (bloco_x * fator + sub_x);
                    
                    // Acumula o pixel lido no ciclo anterior (devido ao delay da ROM)
                    if (pixel_count > 0) begin
                        soma_pixels <= soma_pixels + pixel_rom_reg;
                    end
                    
                    pixel_count <= pixel_count + 1;
                    
                    // Avança coordenadas dentro do bloco usando fator dinâmico
                    if (sub_x >= fator - 1) begin
                        sub_x <= 0;
                        if (sub_y >= fator - 1) begin
                            sub_y <= 0;
                            estado <= CALC_AVERAGE;
                        end else begin
                            sub_y <= sub_y + 1;
                        end
                    end else begin
                        sub_x <= sub_x + 1;
                    end
                end
                
                CALC_AVERAGE: begin
                    // Acumula o último pixel lido
                    soma_pixels <= soma_pixels + pixel_rom_reg;
                    estado <= WRITE_OUTPUT;
                end
                
                WRITE_OUTPUT: begin
                    // Calcula a média dividindo por FATOR² usando fator dinâmico
                    if (fator == 2) begin
                        pixel_saida <= soma_pixels >> 2;  // Divide por 4
                    end else if (fator == 4) begin
                        pixel_saida <= soma_pixels >> 4;  // Divide por 16
                    end else begin
                        pixel_saida <= soma_pixels / fator_quadrado;
                    end
                    
                    // Endereço da RAM VGA para o bloco processado
                    addr_ram_vga <= bloco_y * new_larg + bloco_x;
                    
                    // Avança para o próximo bloco usando dimensões dinâmicas
                    if (bloco_x >= new_larg - 1) begin
                        bloco_x <= 0;
                        if (bloco_y >= new_altura - 1) begin
                            bloco_y <= 0;
                            done <= 1;  // Terminou toda a imagem
                        end else begin
                            bloco_y <= bloco_y + 1;  // Próxima linha de blocos
                        end
                    end else begin
                        bloco_x <= bloco_x + 1;  // Próximo bloco na linha
                    end
                    
                    // Reset para próximo bloco
                    soma_pixels <= 0;
                    pixel_count <= 0;
                    sub_x <= 0;
                    sub_y <= 0;
                    estado <= READ_BLOCK;
                end
            endcase
        end
    end
endmodule