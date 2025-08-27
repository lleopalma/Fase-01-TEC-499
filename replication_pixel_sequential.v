module replication_pixel_sequential 
(
    input wire clock,
    input wire reset,
    output reg [NEW_WIDTH*NEW_HEIGHT*8-1:0] imagem_ampliada
);

    parameter WIDTH = 2,
              HEIGHT = 2,
              NEW_WIDTH = 4,
              NEW_HEIGHT = 4;

    // A imagem original permanece combinacional, pois é um valor fixo.
    wire [WIDTH*HEIGHT*8-1:0] imagem;
    assign imagem = {8'd4, 8'd3, 8'd2, 8'd1};

    // Use registradores para os contadores que irão "percorrer" a imagem original.
    reg [1:0] i, j;
    
    // --- CORREÇÃO: Declaração e atribuição do 'pixel' movidas para fora do bloco 'always'. ---
    wire [7:0] pixel;
    assign pixel = imagem[(i*WIDTH+j)*8 +: 8];
    // -----------------------------------------------------------------------------------------
    
    // A lógica de replicação agora é executada em cada flanco de subida do clock.
    always @(posedge clock or negedge reset) begin
        if (~reset) begin
            // Reset assíncrono: limpa a saída e os contadores.
            imagem_ampliada <= 0;
            i <= 0;
            j <= 0;
        end else begin
            // Replique o pixel para um bloco 2x2 na imagem ampliada.
            // O valor de 'pixel' é lido aqui, mas calculado fora do bloco.
            imagem_ampliada[((2*i)*NEW_WIDTH + (2*j))*8 +: 8] <= pixel;
            imagem_ampliada[((2*i)*NEW_WIDTH + (2*j+1))*8 +: 8] <= pixel;
            imagem_ampliada[((2*i+1)*NEW_WIDTH + (2*j))*8 +: 8] <= pixel;
            imagem_ampliada[((2*i+1)*NEW_WIDTH + (2*j+1))*8 +: 8] <= pixel;

            // Avance os contadores para o próximo pixel original.
            if (j == WIDTH - 1) begin
                j <= 0;
                if (i == HEIGHT - 1)
                    i <= 0; // Se a imagem inteira foi processada, reinicie.
                else
                    i <= i + 1;
            end else begin
                j <= j + 1;
            end
        end
    end

endmodule