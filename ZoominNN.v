module nn_zoom_in (
    parameter largura = 2,
    parameter altura = 2,
    parameter zoom = 2,
    parameter nlargura = zoom * largura,
    parameter naltura = zoom * altura
)(
    input clock,
    input reset
);

    reg [7:0] pixel_in [0 largura*altura-1];
    reg [7:0] pixel_out [0:nlargura*naltura-1];

    
    reg [10:0] linha, coluna, nlinha, ncoluna;

    initial begin
        pixel_in[0] = 8'd2;
        pixel_in[1] = 8'd4;
        pixel_in[2] = 8'd7;
        pixel_in[3] = 8'd9;
    end
    
    always @(posedge clock or negedge reset) begin
        if (~reset) begin
            linha <= 0;
            coluna <= 0;
            nlinha  <= 0;
            ncoluna  <= 0;
        end else begin
            
            pixel_out[(linha*zoom+nlinha)*nlargura + (coluna*zoom+ncoluna)] <= pixel_in[linha largura + coluna];
            
            if (ncoluna == zoom-1) begin
                ncoluna <= 0;
                if (nlinha == zoom-1) begin
                    nlinha <= 0;
                    if (coluna == largura-1) begin
                        coluna <= 0;
                        if (linha == altura-1)
                            linha <= 0;
                        else
                            linha <= linha + 1;
                    end else
                        coluna <= coluna + 1;
                end else
                    nlinha <= nlinha + 1;
            end else
                ncoluna <= ncoluna + 1;
        end
    end

endmodule