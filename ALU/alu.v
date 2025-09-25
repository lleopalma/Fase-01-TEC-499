module alu (
    input clk,
    input reset,                // reset top-level (ativo baixo)
    input [3:0] seletor,        // 00: replicação, 01: decimação, 10: zoom_nn, 11: cópia direta
    output reg saida,
    output reg [18:0] rom_addr,
    input [7:0] rom_data,
    output reg [18:0] ram_wraddr,
    output reg [7:0] ram_data,
    output reg ram_wren,
    output reg done
);

    // Estados da máquina
    reg [3:0] state; // Aumentado para 3 bits para acomodar mais estados
    parameter ST_RESET       = 4'b0111,
            ST_REPLICACAO  = 4'b0000,
            ST_DECIMACAO   = 4'b0001,
            ST_ZOOMNN      = 4'b0010,
			ST_MEDIA       = 4'b0011,
            ST_COPIA_DIRETA = 4'b0100,
            ST_REPLICACAO4  = 4'b1000,
            ST_DECIMACAO4 = 4'b1001,
            ST_ZOOMNN4 = 4'b1010,
            ST_MED4 = 4'b1011;


    // Fios dos submódulos
    wire [18:0] rom_addr_rep;
    wire [18:0] ram_wraddr_rep;
    wire [7:0]  ram_data_rep;
    wire        ram_wren_rep;
    wire        done_rep;
	 
	wire [18:0] rom_addr_rep4;
    wire [18:0] ram_wraddr_rep4;
    wire [7:0]  ram_data_rep4;
    wire        ram_wren_rep4;
    wire        done_rep4;
     
    wire [18:0] rom_addr_dec;
    wire [18:0] ram_wraddr_dec;
    wire [7:0]  ram_data_dec;
    wire        done_dec;
	 
	 
    wire [18:0] rom_addr_dec4;
    wire [18:0] ram_wraddr_dec4;
    wire [7:0]  ram_data_dec4;
    wire        done_dec4;

    wire [18:0] rom_addr_zoom;
    wire [18:0] ram_wraddr_zoom;
    wire [7:0]  ram_data_zoom;
    wire        ram_wren_zoom;
    wire        done_zoom;
	 
	wire [18:0] rom_addr_zoom4;
    wire [18:0] ram_wraddr_zoom4;
    wire [7:0]  ram_data_zoom4;
    wire        ram_wren_zoom4;
    wire        done_zoom4;

    wire [18:0] rom_addr_copia;
    wire [18:0] ram_wraddr_copia;
    wire [7:0]  ram_data_copia;
    wire        ram_wren_copia;
    wire        done_copia;
	 
	wire [18:0] rom_addr_med;
    wire [18:0] ram_wraddr_med;
    wire [7:0]  ram_data_med;
    wire        ram_wren_med;
    wire        done_med;
	 
    wire [18:0] rom_addr_med4;
    wire [18:0] ram_wraddr_med4;
    wire [7:0]  ram_data_med4;
    wire        ram_wren_med4;
    wire        done_med4;


    // Resets dedicados para cada submódulo (active-low)
    reg reset_rep;
    reg reset_rep4;
    reg reset_dec;
    reg reset_dec4;
    reg reset_zoom;
    reg reset_zoom4;
    reg reset_copia;
	reg reset_med;
	reg reset_med4;


    // Instâncias dos submódulos
    replication rep_inst(
        .clk(clk),
        .reset(reset_rep),
		.fator(2),
        .rom_addr(rom_addr_rep),
        .rom_data(rom_data),
        .ram_wraddr(ram_wraddr_rep),
        .ram_data(ram_data_rep),
        .ram_wren(ram_wren_rep),
        .done(done_rep)
    );
	 
	replication rep_inst4(
        .clk(clk),
        .reset(reset_rep4),
        .fator(4),
        .rom_addr(rom_addr_rep4),
        .rom_data(rom_data),
        .ram_wraddr(ram_wraddr_rep4),
        .ram_data(ram_data_rep4),
        .ram_wren(ram_wren_rep4),
        .done(done_rep4)
    ); 
	  
	  
    decimation dec_inst(
        .clk(clk),
        .rst(reset_dec),
		.fator(2),
        .pixel_rom(rom_data),
        .rom_addr(rom_addr_dec),
        .addr_ram_vga(ram_wraddr_dec),
        .pixel_saida(ram_data_dec),
        .done(done_dec)
    );
	 
	decimation dec_inst4(
        .clk(clk),
        .rst(reset_dec4),
		.fator(4),
        .pixel_rom(rom_data),
        .rom_addr(rom_addr_dec4),
        .addr_ram_vga(ram_wraddr_dec4),
        .pixel_saida(ram_data_dec4),
        .done(done_dec4)
    );


    interpolation zoom_inst(
        .clk(clk),
        .reset(reset_zoom),
		.fator(2),
        .rom_addr(rom_addr_zoom),
        .rom_data(rom_data),
        .ram_wraddr(ram_wraddr_zoom),
        .ram_data(ram_data_zoom),
        .ram_wren(ram_wren_zoom),
        .done(done_zoom)
    );

	interpolation zoom_inst4(
        .clk(clk),
        .reset(reset_zoom4),
		.fator(4),
        .rom_addr(rom_addr_zoom4),
        .rom_data(rom_data),
        .ram_wraddr(ram_wraddr_zoom4),
        .ram_data(ram_data_zoom4),
        .ram_wren(ram_wren_zoom4),
        .done(done_zoom4)
    );


    direta copia_inst(
        .clk(clk),
        .reset(reset_copia),
        .rom_addr(rom_addr_copia),
        .rom_data(rom_data),
        .ram_wraddr(ram_wraddr_copia),
        .ram_data(ram_data_copia),
        .ram_wren(ram_wren_copia),
        .done(done_copia)
    );
	 

	averaging med_inst(
        .clk(clk),
        .reset(reset_med),
		.fator(2),
        .pixel_rom(rom_data),
        .rom_addr(rom_addr_med),
        .ram_wraddr(ram_wraddr_med),
        .pixel_saida(ram_data_med),
        .done(done_med)
    );
	 
	averaging med_inst4(
        .clk(clk),
        .reset(reset_med4),
		.fator(4),
        .pixel_rom(rom_data),
        .rom_addr(rom_addr_med4),
        .ram_wraddr(ram_wraddr_med4),
        .pixel_saida(ram_data_med4),
        .done(done_med4)
    );

    initial begin
        state <= ST_RESET;
        saida <= 1'b0;
        rom_addr <= 0;
        ram_wraddr <= 0;
        ram_data <= 0;
        ram_wren <= 0;
        done <= 0;
        reset_rep <= 1'b0;
		reset_rep4 <= 1'b0;
        reset_dec <= 1'b0;
		reset_dec4 <= 1'b0;
        reset_zoom <= 1'b0;
		reset_zoom4 <= 1'b0;
        reset_copia <= 1'b0;
		reset_med <= 1'b0;
		reset_med4 <= 1'b0;
    end

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= ST_RESET;
            saida <= 1'b0;
            rom_addr <= 0;
            ram_wraddr <= 0;
            ram_data <= 0;
            ram_wren <= 0;
            done <= 0;
            reset_rep <= 1'b0;
		      reset_rep4 <= 1'b0;
            reset_dec <= 1'b0;
		      reset_dec4 <= 1'b0;
            reset_zoom <= 1'b0;
		      reset_zoom4 <= 1'b0;
            reset_copia <= 1'b0;
		      reset_med <= 1'b0;
				reset_med4 <= 1'b0;
        end else begin
            case(state)

                // Estado RESET: reseta tudo antes de qualquer operação
                ST_RESET: begin
                    reset_rep <= 1'b0;
		            reset_rep4 <= 1'b0;
                    reset_dec <= 1'b0;
		            reset_dec4 <= 1'b0;
                    reset_zoom <= 1'b0;
		            reset_zoom4 <= 1'b0;
                    reset_copia <= 1'b0;
		            reset_med <= 1'b0;
					reset_med4 <= 1'b0;
                    rom_addr    <= 0;
                    ram_wraddr  <= 0;
                    ram_data    <= 0;
                    ram_wren    <= 0;
                    done        <= 0;

                    // Escolhe próximo estado baseado no seletor
                    case(seletor)
                        4'b0000: state <= ST_REPLICACAO;
                        4'b0001: state <= ST_DECIMACAO;
                        4'b0010: state <= ST_ZOOMNN;
						4'b0011: state <= ST_MEDIA;
                        4'b0100: state <= ST_COPIA_DIRETA;
						4'b1000: state <= ST_REPLICACAO4;
						4'b1001:state <= ST_DECIMACAO4;
						4'b1010: state <= ST_ZOOMNN4;
						4'b1011: state <= ST_MED4;
                        default: state <= ST_RESET;
                    endcase
                end

                ST_REPLICACAO: begin
                    reset_rep   <= 1'b1;
					reset_rep4   <= 1'b0;
                    reset_dec   <= 1'b0;
			      	reset_dec4   <= 1'b0;
                    reset_zoom  <= 1'b0;
					reset_zoom4  <= 1'b0;
                    reset_copia <= 1'b0;
				  	reset_med <= 1'b0;
					reset_med4 <= 1'b0;
                    rom_addr    <= rom_addr_rep;
                    ram_wraddr  <= ram_wraddr_rep;
                    ram_data    <= ram_data_rep;
                    ram_wren    <= ram_wren_rep;
                    done        <= done_rep;

                    if (seletor != 4'b0000) state <= ST_RESET;
                end
					 
				ST_REPLICACAO4: begin
                    reset_rep   <= 1'b0;
					reset_rep4   <= 1'b1;
                    reset_dec   <= 1'b0;
					reset_dec4   <= 1'b0;
                    reset_zoom  <= 1'b0;
					reset_zoom4  <= 1'b0;
                    reset_copia <= 1'b0;
				  	reset_med <= 1'b0;
					reset_med4 <= 1'b0;
                    rom_addr    <= rom_addr_rep4;
                    ram_wraddr  <= ram_wraddr_rep4;
                    ram_data    <= ram_data_rep4;
                    ram_wren    <= ram_wren_rep4;
                    done        <= done_rep4;

                    if (seletor != 4'b1000) state <= ST_RESET;
                end

                ST_DECIMACAO: begin
                    reset_rep   <= 1'b0;
					reset_rep4   <= 1'b0;
                    reset_dec   <= 1'b1;
					reset_dec4   <= 1'b0;
                    reset_zoom  <= 1'b0;
					reset_zoom4  <= 1'b0;
                    reset_copia <= 1'b0;
				  	reset_med <= 1'b0;
					reset_med4 <= 1'b0;
                    rom_addr    <= rom_addr_dec;
                    ram_wraddr  <= ram_wraddr_dec;
                    ram_data    <= ram_data_dec;
                    ram_wren    <= ~done_dec; // continua escrevendo até terminar
                    done        <= done_dec;

                    if (seletor != 4'b0001) state <= ST_RESET;
                end
					 
				ST_DECIMACAO4: begin
					reset_rep   <= 1'b0;
					reset_rep4   <= 1'b0;
                    reset_dec   <= 1'b0;
					reset_dec4   <= 1'b1;
                    reset_zoom  <= 1'b0;
					reset_zoom4  <= 1'b0;
                    reset_copia <= 1'b0;
			  		reset_med <= 1'b0;
					reset_med4 <= 1'b0;
                    rom_addr    <= rom_addr_dec4;
                    ram_wraddr  <= ram_wraddr_dec4;
                    ram_data    <= ram_data_dec4;
                    ram_wren    <= ~done_dec4; // continua escrevendo até terminar
                    done        <= done_dec4;
					if (seletor != 4'b1001) state <= ST_RESET;
				end

                ST_ZOOMNN: begin
                    reset_rep   <= 1'b0;
					reset_rep4   <= 1'b0;
                    reset_dec   <= 1'b0;
					reset_dec4   <= 1'b0;
                    reset_zoom  <= 1'b1;
				    reset_zoom4  <= 1'b0;
                    reset_copia <= 1'b0;
				  	reset_med <= 1'b0;
					reset_med4 <= 1'b0;
                    rom_addr    <= rom_addr_zoom;
                    ram_wraddr  <= ram_wraddr_zoom;
                    ram_data    <= ram_data_zoom;
                    ram_wren    <= ram_wren_zoom;
                    done        <= done_zoom;

                    if (seletor != 4'b0010) state <= ST_RESET;
                end
					 
				ST_ZOOMNN4: begin
                    reset_rep   <= 1'b0;
					reset_rep4   <= 1'b0;
                    reset_dec   <= 1'b0;
					reset_dec4   <= 1'b0;
                    reset_zoom  <= 1'b0;
					reset_zoom4  <= 1'b1;
                    reset_copia <= 1'b0;
					reset_med4 <= 1'b0;
				  	reset_med <= 1'b0;
					reset_med4 <= 1'b0;
                    rom_addr    <= rom_addr_zoom4;
                    ram_wraddr  <= ram_wraddr_zoom4;
                    ram_data    <= ram_data_zoom4;
                    ram_wren    <= ram_wren_zoom4;
                    done        <= done_zoom4;

                    if (seletor != 4'b1010) state <= ST_RESET;
                end
					 
				ST_MEDIA: begin
                    reset_rep   <= 1'b0;
					reset_rep4   <= 1'b0;
                    reset_dec   <= 1'b0;
					reset_dec4   <= 1'b0;
                    reset_zoom  <= 1'b0;
					reset_zoom4  <= 1'b0;
                    reset_copia <= 1'b0;
				  	reset_med <= 1'b1;
					reset_med4 <= 1'b0;
                    rom_addr <= rom_addr_med; 
					ram_wraddr <= ram_wraddr_med; 
					ram_data <= ram_data_med; 
					ram_wren <= ~done_med; 
					done <= done_med;

                    if (seletor != 4'b0011) state <= ST_RESET;
                end

				ST_MED4: begin
                    reset_rep   <= 1'b0;
					reset_rep4   <= 1'b0;
                    reset_dec   <= 1'b0;
					reset_dec4   <= 1'b0;
                    reset_zoom  <= 1'b0;
					reset_zoom4  <= 1'b0;
                    reset_copia <= 1'b0;
				  	reset_med <= 1'b0;
					reset_med4 <= 1'b1;
                    rom_addr <= rom_addr_med4; 
					ram_wraddr <= ram_wraddr_med4; 
					ram_data <= ram_data_med4; 
					ram_wren <= ~done_med4; 
					done <= done_med4;

                    if (seletor != 4'b1011) state <= ST_RESET;
                end

                ST_COPIA_DIRETA: begin
                    reset_rep   <= 1'b0;
				  	reset_med <= 1'b0;  
					reset_dec   <= 1'b0;
                    reset_zoom  <= 1'b0;
                    reset_copia <= 1'b1;
                    rom_addr    <= rom_addr_copia;
                    ram_wraddr  <= ram_wraddr_copia;
                    ram_data    <= ram_data_copia;
                    ram_wren    <= ram_wren_copia;
                    done        <= done_copia;

                    if (seletor != 4'b0100) state <= ST_RESET;
                end

                default: state <= ST_RESET;

            endcase
        end
    end

endmodule