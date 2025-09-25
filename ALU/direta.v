module direta (
    input clk,
    input reset,
    output reg [18:0] rom_addr,
    input [7:0] rom_data,
    output reg [18:0] ram_wraddr,
    output reg [7:0] ram_data,
    output reg ram_wren,
    output reg done
);

    parameter TOTAL_PIXELS = 160*120; // pixels da ROM

    reg [18:0] counter;
    reg [7:0] rom_data_reg;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            counter <= 0;
            rom_addr <= 0;
            ram_wraddr <= 0;
            ram_data <= 0;
            ram_wren <= 0;
            done <= 0;
            rom_data_reg <= 0;
        end else begin
            rom_data_reg <= rom_data; // pega dado com 1 ciclo de atraso

            if (counter < TOTAL_PIXELS) begin
                rom_addr   <= counter;
                ram_wraddr <= counter;
                ram_data   <= rom_data_reg;
                ram_wren   <= 1;
                counter    <= counter + 1;
            end else begin
                ram_wren <= 0;
                done <= 1;
            end
        end
    end
endmodule

// Módulo de replicação de pixel
module rep_pixel(
    input clk,
    input reset,
	 input [2:0] fator,
    output reg [18:0] rom_addr,
    input [7:0] rom_data,
    output reg [18:0] ram_wraddr,
    output reg [7:0] ram_data,
    output reg ram_wren,
    output reg done
);

    
    parameter LARGURA = 160;
    parameter ALTURA = 120;
    wire [11:0] NEW_LARG = LARGURA * fator;
    wire [11:0] NEW_ALTURA = ALTURA * fator;

    reg [10:0] linha, coluna, di, dj;
    reg [7:0] rom_data_reg;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
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
                
                // Calcula endereço da RAM (pixel ampliado)
                ram_wraddr <= (linha * fator + di) * NEW_LARG + (coluna * fator + dj);
                
                // Dado a ser escrito na RAM (mesmo pixel repetido)
                ram_data <= rom_data_reg;
                ram_wren <= 1;
                
                // Lógica de avanço nos contadores
                if (dj == fator - 1) begin
                    dj <= 0;
                    if (di == fator - 1) begin
                        di <= 0;
                        if (coluna == LARGURA - 1) begin
                            coluna <= 0;
                            if (linha == ALTURA - 1) begin
                                linha <= 0;
                                done <= 1;
                                ram_wren <= 0;
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
                ram_wren <= 0;
            end
        end
    end

endmodule