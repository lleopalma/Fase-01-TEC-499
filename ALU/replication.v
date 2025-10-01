module replication(
    input clk,
    input reset,
    input sw,
    output reg [18:0] rom_addr,
    input [7:0] rom_data,          
    output reg [18:0] ram_wraddr,
    output reg [7:0] ram_data,
    output reg ram_wren,
    output reg done
);
    parameter LARGURA = 160;
    parameter ALTURA = 120;
    
    // Sinais para fator dinâmico e dimensões de saída
    reg [2:0] fator;
    reg [10:0] new_larg, new_altura;
    
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
    
    reg [10:0] linha, coluna, di, dj;
    reg [7:0] rom_data_reg;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rom_addr <= 0;
            ram_wraddr <= 0;
            ram_data <= 0;
            ram_wren <= 0;
            done <= 0;
            linha <= 0;
            coluna <= 0;
            di <= 0;
            dj <= 0;
            rom_data_reg <= 0;
        end else begin
            // Registra o dado da ROM com 1 ciclo de atraso
            rom_data_reg <= rom_data;
            
            if (!done) begin
                // Calcula endereço da ROM (pixel original)
                rom_addr <= linha * LARGURA + coluna;
                
                // Calcula endereço da RAM (pixel ampliado) usando valores dinâmicos
                ram_wraddr <= (linha * fator + di) * new_larg + (coluna * fator + dj);
                
                // Dado a ser escrito na RAM (mesmo pixel repetido)
                ram_data <= rom_data_reg;
                ram_wren <= 1;
                
                // Lógica de avanço nos contadores usando fator dinâmico
                if (dj == fator - 1) begin
                    dj <= 0;
                    if (di == fator - 1) begin
                        di <= 0;
                        if (coluna == LARGURA - 1) begin
                            coluna <= 0;
                            if (linha == ALTURA - 1) begin
                                linha <= 0;
                                done <= 1;
                                ram_wren <= 0; // Finaliza escrita
                            end else begin
                                linha <= linha + 1;
                            end
                        end else begin
                            coluna <= coluna + 1;
                        end
                    end else begin
                        di <= di + 1;
                    end
                end else begin
                    dj <= dj + 1;
                end
            end else begin
                ram_wren <= 0; // Mantém wren desativado após conclusão
            end
        end
    end
endmodule