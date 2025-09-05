/*module ALU (
    opcode,
    op2,
    clk,
    result
);

input [1:0] opcode;
input op2;
input clk;
output result;

always @(posedge(clk)) begin
    case (opcode)
        2'b00:  
        2'b01:
        2'b10:
    
end
*/
    
endmodule

/*module ALU
#(
    parameter LARGURA = 320,
    parameter ALTURA = 240,
    parameter FATOR = 2
)
(
    input clk,
    input reset,
    input [1:0] op_sel,          // Seleção de operação
    input wire [7:0] pixel_in,    // Entrada de pixel único (para block averaging)
    input wire [(LARGURA*8 - 1):0] buffer_in, // Buffer de entrada para outras operações
    output reg [7:0] pixel_out,   // Saída de pixel único
    output wire [(LARGURA*8 - 1):0] buffer_out // Buffer de saída
);

    // Definições dos códigos de operação
    localparam OP_BLOCK_AVG = 2'b00;
    localparam OP_NN_ZOOM_OUT = 2'b01;
    localparam OP_PIXEL_REPLICATION = 2'b10;
    localparam OP_PASSTHROUGH = 2'b11;

    // Sinais internos
    wire [7:0] block_avg_out;
    wire [(LARGURA*8 - 1):0] nn_zoom_out_buf;
    wire [(LARGURA*8 - 1):0] pixel_replication_buf;

    // Instância do módulo de block averaging
    block_averaging #(
        .largura(LARGURA),
        .altura(ALTURA),
        .fator(FATOR)
    ) block_avg_inst (
        .clk(clk),
        .reset(reset),
        .pixel_in(pixel_in),
        .pixel_out(block_avg_out)
    );

    // Instância do módulo de nearest-neighbor zoom out
    nn_zoom_out #(
        .largura(LARGURA),
        .altura(ALTURA),
        .fator(FATOR)
    ) nn_zoom_inst (
        .clk(clk),
        .reset(reset),
        .buffer_pixel_in(buffer_in),
        .buffer_pixel_out(nn_zoom_out_buf)
    );

    // Instância do módulo de pixel replication
    replication_pixel #(
        .largura(LARGURA),
        .altura(ALTURA),
        .fator(FATOR)
    ) pixel_replication_inst (
        .clk(clk),
        .reset(reset),
        .buffer_pixel_in(buffer_in),
        .buffer_pixel_out(pixel_replication_buf)
    );

    // Lógica de seleção de operação para saída de buffer
    assign buffer_out = (op_sel == OP_NN_ZOOM_OUT) ? nn_zoom_out_buf :
                       (op_sel == OP_PIXEL_REPLICATION) ? pixel_replication_buf :
                       (op_sel == OP_PASSTHROUGH) ? buffer_in :
                       {LARGURA*8{1'b0}}; // Default: zeros

    // Lógica de seleção de operação para saída de pixel único
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pixel_out <= 8'b0;
        end else begin
            if (op_sel == OP_BLOCK_AVG) begin
                pixel_out <= block_avg_out;
            end else begin
                pixel_out <= 8'b0; // Para outras operações, pixel_out é zero
            end
        end
    end

endmodule*/