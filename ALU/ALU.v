module alu
(
	input wire clock,
	input wire [3:0] opcode,
	input wire start,
	input wire [31:0] buffer_pixels_in_alu,
	output reg [63:0] buffer_pixels_out_alu,
	output reg done_alu
);
	
	wire [63:0] buffer_tmp_alu_rp;
	wire [63:0] buffer_tmp_alu_dc;
	wire [63:0] buffer_tmp_alu_ba;
	
	replication_pixel inst_rp (buffer_pixels_in_alu, buffer_tmp_alu_rp);
	decimation inst_dc(buffer_pixels_in_alu, buffer_tmp_alu_dc);
	block_averaging inst_ba (buffer_pixels_in_alu, buffer_tmp_alu_ba);
	
	always@(posedge clock) 
    begin 
		  if (!start) 
		  begin
            done_alu <= 0;
				buffer_pixels_out_alu <= 64'd0;
        end 
		  
		  else
        begin
            if(start & !done_alu)
            begin
                case (opcode)
                    4'b0000:
                    begin
							done_alu <= 1;
                    end
						  4'b0001:
						  begin
							buffer_pixels_out_alu <= buffer_tmp_alu_rp;
							done_alu <= 1;
						  end
						  4'b0010: 
						  begin
							buffer_pixels_out_alu <= buffer_tmp_alu_dc;
							done_alu <= 1;
						  end
						  4'b0011:
						  begin
							buffer_pixels_out_alu <= buffer_tmp_alu_ba;
							done_alu <= 1;
						  end
						  
						  default:
						  begin
							done_alu <= 1;
						  end
                endcase
            end
        end
    end
endmodule