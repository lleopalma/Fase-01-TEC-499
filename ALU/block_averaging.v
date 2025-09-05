module block_averaging
#(
    parameter largura = 320,
    parameter altura = 240,
    parameter fator = 2
)
(
    input clk,
    input reset,
    input wire [7:0] pixel_in,
    output reg [7:0] pixel_out
);

    localparam num_pixels_in = fator*fator;
    reg [3:0] contador;
    reg [11:0] soma;

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            contador <= 0;
            soma <= 0;
            pixel_out <= 0;
        end

        else
        begin
            if (contador == num_pixels_in)
            begin
                pixel_out <= soma >> 2;
                contador <= 0;
                soma <= 0;
            end

            else 
            begin
                soma <= soma + pixel_in;
                contador <= contador + 1;
            end    
        end
    end

endmodule