module interpolation (
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
    parameter ALTURA  = 120;

    reg [11:0] NEW_LARG;

    // Variáveis auxiliares
    reg [7:0] rom_data_reg;
    reg [10:0] linha, coluna, di, dj;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            linha <= 0; coluna <= 0; di <= 0; dj <= 0;
            rom_addr <= 0; ram_wraddr <= 0;
            rom_data_reg <= 0; ram_data <= 0;
            ram_wren <= 0; done <= 0;
            NEW_LARG <= 0;
        end else begin
            rom_data_reg <= rom_data;

            if (NEW_LARG == 0)
                NEW_LARG <= LARGURA * fator;
            else if (!done) begin
                ram_wren <= 1;
                ram_data <= rom_data_reg;

                // Endereço da ROM (só avança no primeiro ciclo do bloco de replicação)
                if (di == 0 && dj == 0)
                    rom_addr <= linha * LARGURA + coluna;

                // Endereço da RAM
                ram_wraddr <= (linha * fator + di) * NEW_LARG + (coluna * fator + dj);

                // Avanço dos contadores internos
                if (dj == fator - 1) begin
                    dj <= 0;
                    if (di == fator - 1) begin
                        di <= 0;
                        if (coluna == LARGURA - 1) begin
                            coluna <= 0;
                            if (linha == ALTURA - 1) begin
                                linha <= 0;
                                done <= 1;
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