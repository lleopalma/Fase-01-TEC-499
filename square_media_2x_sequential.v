module square_media_2x_sequential 
(
    input wire clock,
    input wire reset,
    output reg [127:0] imagem_reduzida
);

    parameter LARGURA = 8;
    parameter ALTURA = 8;
    parameter NOVA_LARGURA = 4;
    parameter NOVA_ALTURA = 4;

    wire [511:0] imagem;
    assign imagem = {
        8'd63, 8'd62, 8'd61, 8'd60, 8'd59, 8'd58, 8'd57, 8'd56,
        8'd55, 8'd54, 8'd53, 8'd52, 8'd51, 8'd50, 8'd49, 8'd48,
        8'd47, 8'd46, 8'd45, 8'd44, 8'd43, 8'd42, 8'd41, 8'd40,
        8'd39, 8'd38, 8'd37, 8'd36, 8'd35, 8'd34, 8'd33, 8'd32,
        8'd31, 8'd30, 8'd29, 8'd28, 8'd27, 8'd26, 8'd25, 8'd24,
        8'd23, 8'd22, 8'd21, 8'd20, 8'd19, 8'd18, 8'd17, 8'd16,
        8'd15, 8'd14, 8'd13, 8'd12, 8'd11, 8'd10, 8'd9, 8'd8,
        8'd7, 8'd6, 8'd5, 8'd4, 8'd3, 8'd2, 8'd1, 8'd0
    };

    // Registradores para contadores
    reg [2:0] linha, coluna;

    // --- CORREÇÃO: Mova as declarações de wire para fora do bloco always. ---
    // Acessam a imagem de forma combinacional com base nos contadores.
    wire [7:0] p1, p2, p3, p4;
    wire [9:0] soma;

    // Assegura que os pixels são extraídos corretamente da imagem original
    assign p1 = imagem[((linha*2)*LARGURA + coluna*2)*8 +: 8];
    assign p2 = imagem[((linha*2)*LARGURA + coluna*2 + 1)*8 +: 8];
    assign p3 = imagem[((linha*2 + 1)*LARGURA + coluna*2)*8 +: 8];
    assign p4 = imagem[((linha*2 + 1)*LARGURA + coluna*2 + 1)*8 +: 8];
    
    // Calcula a soma e a média combinacionalmente
    assign soma = p1 + p2 + p3 + p4;

    // Lógica sequencial para processar a imagem bloco por bloco
    always @(posedge clock or negedge reset) begin
        if (~reset) begin
            linha <= 0;
            coluna <= 0;
            imagem_reduzida <= 0;
        end else begin
            // Atribui a média (já calculada pelo 'soma' wire) à imagem reduzida
            imagem_reduzida[(linha*NOVA_LARGURA + coluna) * 8 +: 8] <= soma >> 2;

            // Incrementa os contadores para mover para o próximo bloco 2x2
            if (coluna == NOVA_LARGURA - 1) begin
                coluna <= 0;
                if (linha == NOVA_ALTURA - 1)
                    linha <= 0;
                else
                    linha <= linha + 1;
            end else begin
                coluna <= coluna + 1;
            end
        end
    end
endmodule