module rom_to_ram (
    input clk,
    input reset,
    input [2:0] seletor, // 00: replicação, 01: decimação, 10: vizinho, 11: média
    input decoding,
    input sw,
    output reg [18:0] rom_addr,
    input [7:0] rom_data,
    output reg [18:0] ram_wraddr,
    output reg [7:0] ram_data,
    output reg ram_wren,
    output reg done
);
    
    // Registradores para detectar mudanças no seletor e no sw
    reg [2:0] seletor_prev;
    reg sw_prev;
    wire seletor_changed = (seletor != seletor_prev);
    wire sw_changed = (sw != sw_prev);
    
    // Detecta mudanças no seletor e no sw
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            seletor_prev <= 3'b000;
            sw_prev <= 1'b0;
        end else begin
            seletor_prev <= seletor;
            sw_prev <= sw;
        end
    end
    
    // Reset automático quando muda o seletor, o fator (sw), ou reset manual
    wire auto_reset = reset || seletor_changed || sw_changed;
    
    // Fios para conectar aos módulos
    wire [18:0] rom_addr_rep, rom_addr_dec, rom_addr_nn, rom_addr_med;
    wire [18:0] ram_wraddr_rep, ram_wraddr_dec, ram_wraddr_nn, ram_wraddr_med;
    wire [7:0] ram_data_rep, ram_data_dec, ram_data_nn, ram_data_med;
    wire ram_wren_rep, ram_wren_dec, ram_wren_nn, ram_wren_med;
    wire done_rep, done_dec, done_nn, done_med;
    
    // Instâncias dos módulos com reset automático
    replication rep_inst(
        .clk(clk),
        .reset(auto_reset),
        .sw(sw),
        .rom_addr(rom_addr_rep),
        .rom_data(rom_data),
        .ram_wraddr(ram_wraddr_rep),
        .ram_data(ram_data_rep),
        .ram_wren(ram_wren_rep),
        .done(done_rep)
    );
    
    decimation dec_inst(
        .clk(clk),
        .rst(auto_reset),
        .pixel_rom(rom_data),
        .sw(sw),
        .rom_addr(rom_addr_dec),
        .addr_ram_vga(ram_wraddr_dec),
        .pixel_saida(ram_data_dec),
        .done(done_dec)
    );
    
    nearest_neighbor nn (
        .clk(clk),
        .rst(auto_reset),
        .pixel_rom(rom_data),
        .sw(sw),
        .rom_addr(rom_addr_nn),
        .addr_ram_vga(ram_wraddr_nn),
        .pixel_saida(ram_data_nn),
        .done(done_nn)
    );
    
    media med(
        .clk(clk),
        .rst(auto_reset),
        .pixel_rom(rom_data),
        .sw(sw),
        .rom_addr(rom_addr_med),
        .addr_ram_vga(ram_wraddr_med),
        .pixel_saida(ram_data_med),
        .done(done_med)
    );
    
    assign ram_wren_dec = ~done_dec;
    assign ram_wren_nn = ~done_nn;
    assign ram_wren_med = ~done_med;
    
    // Multiplexador
    always @(*) begin
        if(decoding) begin
            case(seletor)
                3'b001: begin  // REPLICAÇÃO
                    rom_addr = rom_addr_rep;
                    ram_wraddr = ram_wraddr_rep;
                    ram_data = ram_data_rep;
                    ram_wren = ram_wren_rep;
                    done = done_rep;
                end
                3'b010: begin  // DECIMAÇÃO
                    rom_addr = rom_addr_dec;
                    ram_wraddr = ram_wraddr_dec;
                    ram_data = ram_data_dec;
                    ram_wren = ram_wren_dec;
                    done = done_dec;
                end
                3'b011: begin  // NEAREST NEIGHBOR
                    rom_addr = rom_addr_nn;
                    ram_wraddr = ram_wraddr_nn;
                    ram_data = ram_data_nn;
                    ram_wren = ram_wren_nn;
                    done = done_nn;
                end
                3'b100: begin  // MÉDIA
                    rom_addr = rom_addr_med;
                    ram_wraddr = ram_wraddr_med;
                    ram_data = ram_data_med;
                    ram_wren = ram_wren_med;
                    done = done_med;
                end
                default: begin
                    rom_addr = 19'b0;
                    ram_wraddr = 19'b0;
                    ram_data = 8'b0;
                    ram_wren = 1'b0;
                    done = 1'b0;
                end
            endcase
        end else begin
            // Quando decoding = 0, zera as saídas
            rom_addr = 19'b0;
            ram_wraddr = 19'b0;
            ram_data = 8'b0;
            ram_wren = 1'b0;
            done = 1'b0;
        end
    end
endmodule