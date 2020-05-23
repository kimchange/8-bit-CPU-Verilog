`timescale 1ns / 1ps
module control_unit(clk, rst, ram_data, ram_read_en, ram_write_en, ram_address, opcode, alu_in_A, alu_in_B, alu_out, overflow, zero, negative);

input clk, rst, overflow, zero, negative ;   		// clock, reset
input [7:0] alu_out;

output reg ram_read_en, ram_write_en;
output reg [7:0] alu_in_A, alu_in_B;
output reg [3:0] opcode;
output reg [3:0] ram_address;

// 相当于control_unit和ram之间的databus
inout [7:0] ram_data;


reg [7:0] Register[0:3];
reg [3:0] PC;
reg [2:0] state;

// 仅做仿真时观察波形使用：begin
wire [7:0] test_Register0, test_Register1, test_Register2, test_Register3; 
assign test_Register0 = Register[0];
assign test_Register1 = Register[1];
assign test_Register2 = Register[2];
assign test_Register3 = Register[3];
// 仅做仿真时观察波形使用：end
// 有关仿真时数组再iverilog的显示问题，参考了
// https://stackoverflow.com/questions/20317820/icarus-verilog-dump-memory-array-dumpvars
// 原因：iverilog 仿真时就是不能 dump 数组

// 相当于control_unit和ram之间的databus
assign ram_data = (ram_write_en)? Register[0]:8'hzz;

// instruction code
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

// state encoding one-hot			 
parameter	S0 = 3'b001,
			S1 = 3'b010,
			S2 = 3'b100;

initial
	begin
		state = S0;
		PC = 4'b0000;
		ram_address = 4'b0000;
		opcode = HALT;
		alu_in_A	= 8'b0000_0000;
		alu_in_B 	= 8'b0000_0000;
		Register[0] = 8'b0000_0000;
		Register[1] = 8'b0000_0000;
		Register[2] = 8'b0000_0000;
		Register[3] = 8'b0000_0000;
		ram_read_en = 1'b0;
		ram_write_en = 1'b0;

		//通用寄存器初始化
	end
    


always@(posedge clk)
begin
	case(state)
	// 取指令
	S0: begin
		ram_address <= PC;
		ram_read_en <= 1'b1;
		ram_write_en<= 1'b0;
		opcode <= ram_data[7:4];
		if (opcode == HALT || rst) begin
			state <= S0;
			
		end else begin
			PC <= PC + 1;
			state <= S1;

		end
	end
	// 指令译码(对号入座)和执行指令
	S1: begin
		if ((opcode == LOAD_A) || (opcode == LOAD_B)) begin
			ram_address <= ram_data[3:0];
			ram_read_en <= 1'b1;
			ram_write_en<= 1'b0;
			state <= S2;

			
		end else if ((opcode == ADD) || (opcode == SUB)) begin
			alu_in_B <= Register[ram_data[3:2]];
			alu_in_A <= Register[ram_data[1:0]];
			state <= S2;
			
			
		end else if (opcode == JUMP) begin
			PC <= ram_data[3:0];
			state <= S2;

		end else if (opcode == JUMP_NEG) begin
			PC <= negative ? ram_data[3:0] : (PC);
			state <= S2;
			
		end else if (opcode == STORE_A) begin
			ram_address <= ram_data[3:0];
			ram_read_en <= 1'b0;
			ram_write_en <= 1'b1;
			state <= S2;

		end else begin
			state <= S0;
		end
		
	end
	// 写入寄存器或RAM以及准备复位
	S2: begin
		case (opcode)
			LOAD_A: begin 
				Register[0] <= ram_data[7:0];
				ram_address <= PC;
				state <= S0;
			end
			LOAD_B: begin
				Register[1] <= ram_data[7:0];
				ram_address <= PC;
				state <= S0;
			end
			ADD: begin
				Register[ram_data[1:0]] <= alu_out;
				ram_address <= PC;
				state <= S0; 
			end
			SUB: begin
				Register[ram_data[1:0]] <= alu_out;
				ram_address <= PC;
				state <= S0;
				
			end
			STORE_A: begin
				ram_read_en <= 1'b1;
				ram_write_en <= 1'b0;
				ram_address <= PC;
				
				state <= S0;
			end
			JUMP: begin
				ram_address <= PC;
				state <= S0;
			end
			JUMP_NEG: begin
				ram_address <= PC;
				state <= S0;
			end

			default: state <= S0;
		endcase
	end

	default: begin
		state <= S0;
		ram_read_en  <= 1'b0;
		ram_write_en <= 1'b0;
		ram_address <= 4'b0000;
		opcode <= HALT;
	end
endcase
end

endmodule
