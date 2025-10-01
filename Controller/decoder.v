module decoder (
	input [3:0] sw,
	output [2:0] opcode,
	output decoding
);
	
	assign opcode = (sw == 4'b1000) ? 3'b001 : 
						(sw == 4'b0100) ? 3'b010 :
						(sw == 4'b0010) ? 3'b011 :
						(sw == 4'b0001) ? 3'b100 :
						3'b000;
						
	assign decoding = (sw == 4'b1000) ? 1'b1 : 
						(sw == 4'b0100) ? 1'b1 :
						(sw == 4'b0010) ? 1'b1 :
						(sw == 4'b0001) ? 1'b1 :
						1'b0;					
						
endmodule