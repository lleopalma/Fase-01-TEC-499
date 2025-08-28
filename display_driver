module display_driver (
    input wire clock,
    input wire reset,
    input wire [3:0] digito6, // MSB - Módulo
    input wire [3:0] digito5, // Índice do pixel (dezena)
    input wire [3:0] digito4, // Índice do pixel (unidade)
    input wire [3:0] digito3, // Valor do pixel (centena)
    input wire [3:0] digito2, // Valor do pixel (dezena)
    input wire [3:0] digito1, // LSB - Valor do pixel (unidade)
    output reg [6:0] segmentos, // Saída para os segmentos (a,b,c,d,e,f,g)
    output reg [5:0] anodo      // Controle de qual dígito está ativo
);

    // Divisor de clock para taxa de atualização do display (e.g., ~488 Hz para clock de 50 MHz)
    reg [16:0] contador_refresh;
    always @(posedge clock or negedge reset) begin
        if (~reset)
            contador_refresh <= 0;
        else
            contador_refresh <= contador_refresh + 1;
    end

    // Contador para selecionar o dígito a ser exibido
    reg [2:0] seletor_digito;
    always @(posedge contador_refresh[16]) begin // Usa um bit alto do contador como clock
        if (~reset)
            seletor_digito <= 0;
        else
            seletor_digito <= seletor_digito + 1;
    end

    // Multiplexador para os dados de entrada
    reg [3:0] dados_bcd;
    always @* begin
        case (seletor_digito)
            3'd0: dados_bcd = digito1;
            3'd1: dados_bcd = digito2;
            3'd2: dados_bcd = digito3;
            3'd3: dados_bcd = digito4;
            3'd4: dados_bcd = digito5;
            3'd5: dados_bcd = digito6;
            default: dados_bcd = 4'b0000;
        endcase
    end

    // Decodificador de BCD para 7 segmentos (catodo comum)
    always @* begin
        case (dados_bcd)
            4'h0: segmentos = 7'b0111111; // 0
            4'h1: segmentos = 7'b0000110; // 1
            4'h2: segmentos = 7'b1011011; // 2
            4'h3: segmentos = 7'b1001111; // 3
            4'h4: segmentos = 7'b1100110; // 4
            4'h5: segmentos = 7'b1101101; // 5
            4'h6: segmentos = 7'b1111101; // 6
            4'h7: segmentos = 7'b0000111; // 7
            4'h8: segmentos = 7'b1111111; // 8
            4'h9: segmentos = 7'b1101111; // 9
            default: segmentos = 7'b0000000; // Apagado
        endcase
    end

    // Controle dos anodos (ativo baixo)
    always @(seletor_digito) begin
        case (seletor_digito)
            3'd0: anodo = 6'b111110;
            3'd1: anodo = 6'b111101;
            3'd2: anodo = 6'b111011;
            3'd3: anodo = 6'b110111;
            3'd4: anodo = 6'b101111;
            3'd5: anodo = 6'b011111;
            default: anodo = 6'b111111;
        endcase
    end

endmodule
