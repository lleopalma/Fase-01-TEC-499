module nn_zoom_out (
    input wire clock,
    input wire reset,
    output reg [31:0] pixel_out
);
   
    parameter largura = 4,  
              altura = 4,    
              zoom_out = 2,  
              nlargura = largura / zoom_out,  
              naltura = altura / zoom_out;  
 
    reg [7:0] pixel_in [0: largura*altura-1];  

    reg [10:0] nlinha, ncoluna;

    initial begin
        pixel_in[0] = 8'd1;
        pixel_in[1] = 8'd2;
        pixel_in[2] = 8'd3;
        pixel_in[3] = 8'd4;
        pixel_in[4] = 8'd5;
        pixel_in[5] = 8'd6;
        pixel_in[6] = 8'd7;
        pixel_in[7] = 8'd8;
        pixel_in[8] = 8'd9;
        pixel_in[9] = 8'd10;
        pixel_in[10] = 8'd11;
        pixel_in[11] = 8'd12;
        pixel_in[12] = 8'd13;
        pixel_in[13] = 8'd14;
        pixel_in[14] = 8'd15;
        pixel_in[15] = 8'd16;
    end

    always @(posedge clock or negedge reset) begin
        if (~reset) begin
            nlinha <= 0;
            ncoluna <= 0;
        end else begin
            // A ordem de escrita foi invertida para preencher o vetor da esquerda para a direita
            pixel_out[ ((naltura - 1 - nlinha) * nlargura + (nlargura - 1 - ncoluna)) * 8 +: 8 ] <= pixel_in[(nlinha * zoom_out) * largura + (ncoluna * zoom_out)];

            if (ncoluna == nlargura - 1) begin
                ncoluna <= 0;
                if (nlinha == naltura - 1)
                    nlinha <= 0;
                else
                    nlinha <= nlinha + 1;
            end else begin
                ncoluna <= ncoluna + 1;
            end
        end
    end
endmodule