module averaging (
    input clk,
    input reset,
    input [2:0] fator,  // Suporta valores como 2, 4, etc.
    input [7:0] pixel_rom,
    output reg [18:0] rom_addr,
    output reg [18:0] ram_wraddr,
    output reg [7:0] pixel_saida,
    output reg done
);

    parameter LARGURA = 160;
    parameter ALTURA  = 120;

    reg [11:0] NEW_LARG, NEW_ALTURA;

    reg [10:0] bloco_x, bloco_y;
    reg [3:0] sub_x, sub_y;
    reg [15:0] soma_pixels;
    reg [3:0] pixel_count;
    reg [1:0] estado;
    localparam IDLE = 2'b00, READ_BLOCK = 2'b01, CALC_AVERAGE = 2'b10, WRITE_OUTPUT = 2'b11;
    reg [7:0] pixel_rom_reg;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            rom_addr <= 0; ram_wraddr <= 0; pixel_saida <= 0; done <= 0;
            bloco_x <= 0; bloco_y <= 0; sub_x <= 0; sub_y <= 0;
            soma_pixels <= 0; pixel_count <= 0; estado <= IDLE; pixel_rom_reg <= 0;
            NEW_LARG <= 0; NEW_ALTURA <= 0;
        end else begin
            pixel_rom_reg <= pixel_rom;

            // Só calcula NEW_LARG uma vez
            if (NEW_LARG == 0) begin
                NEW_LARG <= LARGURA / fator;
                NEW_ALTURA <= ALTURA / fator;
            end

            case(estado)
                IDLE: begin
                    soma_pixels <= 0; pixel_count <= 0;
                    sub_x <= 0; sub_y <= 0;
                    estado <= READ_BLOCK;
                end

                READ_BLOCK: begin
                    rom_addr <= (bloco_y*fator + sub_y)*LARGURA + (bloco_x*fator + sub_x);
                    if (pixel_count > 0) soma_pixels <= soma_pixels + pixel_rom_reg;
                    pixel_count <= pixel_count + 1;

                    if (sub_x >= fator - 1) begin
                        sub_x <= 0;
                        if (sub_y >= fator - 1)
                            estado <= CALC_AVERAGE;
                        else
                            sub_y <= sub_y + 1;
                    end else
                        sub_x <= sub_x + 1;
                end

                CALC_AVERAGE: begin
                    soma_pixels <= soma_pixels + pixel_rom_reg;
                    estado <= WRITE_OUTPUT;
                end

                WRITE_OUTPUT: begin
                    // Calcula média
                    if (fator == 2)
                        pixel_saida <= soma_pixels >> 2; // 4 = 2^2
                    else if (fator == 4)
                        pixel_saida <= soma_pixels >> 4; // 16 = 2^4
                    else
                        pixel_saida <= soma_pixels / (fator*fator); // fallback

                    ram_wraddr <= bloco_y * NEW_LARG + bloco_x;

                    // Avança para o próximo bloco
                    if (bloco_x >= NEW_LARG - 1) begin
                        bloco_x <= 0;
                        if (bloco_y >= NEW_ALTURA - 1) begin
                            bloco_y <= 0;
                            done <= 1;
                        end else
                            bloco_y <= bloco_y + 1;
                    end else
                        bloco_x <= bloco_x + 1;

                    soma_pixels <= 0; pixel_count <= 0;
                    sub_x <= 0; sub_y <= 0;
                    estado <= READ_BLOCK;
                end
            endcase
        end
    end
endmodule