`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
module alu(opcode, alu_in_A, alu_in_B, alu_out, overflow, zero, negative);//  arithmetic logic unit
input [3:0] opcode;
input [7:0] alu_in_A, alu_in_B;
output reg [7:0] alu_out;
output reg overflow;
output reg zero;
output reg negative;

reg extra;

parameter 	HALT     = 4'b0000,
			LOAD_A   = 4'b0010,
			LOAD_B   = 4'b0001,
			STORE_A  = 4'b0100,
			ADD      = 4'b1000,
			SUB      = 4'b1001,
			JUMP     = 4'b1010,
			JUMP_NEG = 4'b1011,
			WIDTH    = 8,
			MSB      = WIDTH - 1;


initial
	begin
		alu_out = 8'b00000000;
		overflow = 1'b0;
		zero = 1'b0;
		negative = 1'b0;
		extra = 1'b0;

		//通用寄存器初始化
	end

always @(*) begin
		case (opcode)
		ADD:
		begin
			{extra, alu_out} = {alu_in_A[MSB], alu_in_A} + {alu_in_B[MSB], alu_in_B};
			overflow  = ({extra, alu_out[MSB]} == 2'b01) || ({extra, alu_out[MSB]} == 2'b10);
			zero = alu_out ? 0 : 1;
			negative = alu_out[MSB];
		end
		SUB:
		begin
			if (!alu_in_B) begin
				alu_out = alu_in_A;
				overflow  = 1'b0;
				zero = alu_out ? 0 : 1;
				negative = alu_out[MSB];
			end else begin
				{extra, alu_out} = {alu_in_A[MSB], alu_in_A} + ~{alu_in_B[MSB], alu_in_B} + 9'b000000001;
				overflow  = ({extra, alu_out[MSB]} == 2'b01) || ({extra, alu_out[MSB]} == 2'b10);
				zero = alu_out ? 0 : 1;
				negative = alu_out[MSB];
			end
		end

		default:	alu_out = 8'bzzzz_zzzz;
		endcase
end

endmodule
