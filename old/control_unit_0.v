module control_unit(clk, rst, PC, ram_data, ram_read_en, ram_write_en, ram_address, opcode, alu_in_A, alu_in_B, alu_out, overflow, zero, negative);

input clk, rst, overflow, zero, negative ;   		// clock, reset
input [7:0] alu_out;

output reg ram_read_en, ram_write_en;
output reg [7:0] alu_in_A, alu_in_B;
output reg [3:0] opcode;
output reg [3:0] ram_address;
output reg [3:0] PC;

inout [7:0] ram_data;


reg [7:0] Register[3:0];
reg [2:0] state;
reg [2:0] next_state;

assign ram_data = (ram_write_en)? Register[ram_address]:8'hzz;


// instruction code
parameter 	NOP      = 8'b00000000,
			LOAD_A   = 4'b0010,
			LOAD_B   = 4'b0001,
			STORE_A  = 4'b0100,
			ADD      = 4'b1000,
			SUB      = 4'b1001,
			JUMP     = 4'b1010,
			JUMP_NEG = 4'b1011,
			HALT     = 4'b0000,
			WIDTH    = 8,
			MSB      = WIDTH - 1;

// state encoding one-hot			 
parameter	S0 = 3'b001,
			S1 = 3'b010,
			S2 = 3'b100;

initial
	begin
		state = S0;
		next_state = S1;
		PC = 4'b0000;
		ram_address = 4'b0000;
		opcode = NOP;
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
    
//PART A: D flip latch; State register
always @(posedge clk or negedge rst) 
begin
	if(!rst) state <= S0;
	else state <= next_state;
end



// another style
//PART C: Output combinational logic

always@(posedge clk)
begin
	case(state)
	S0: begin
		ram_address <= PC;
		ram_read_en <= 1'b1;
		ram_write_en<= 1'b0;
		if (opcode == HALT) begin
			next_state <= S0;
			
		end else begin
			PC <= PC + 1;
			next_state <= S1;

		end
	end

	S1: begin
		if ((opcode == LOAD_A) || (opcode == LOAD_B)) begin
			opcode 		<= ram_data[7:4];
			ram_address <= ram_data[3:0];
			ram_read_en <= 1'b1;
			ram_write_en<= 1'b0;
			next_state = S2;

			
		end else if ((opcode == ADD) || (opcode == SUB)) begin
			alu_in_A <= Register[ram_data[3:2]];
			alu_in_B <= Register[ram_data[1:0]];
			next_state = S2;
			
			
		end else if (opcode == JUMP) begin
			PC <= ram_data[3:0];
			next_state = S0;
		end else if (opcode == JUMP_NEG) begin
			PC <= negative ? ram_data[3:0] : (PC + 1);
			next_state = S0;
		end else if (opcode == STORE_A) begin
			ram_address <= ram_data[3:0];
			ram_read_en <= 1'b0;
			ram_write_en <= 1'b1;
			next_state = S2;

		end else begin
			next_state <= S0;
		end
		
	end
	S2: begin
		case (opcode)
			LOAD_A: begin 
				Register[0] <= ram_data[7:0];
				next_state <= S0;
			end
			LOAD_B: begin
				Register[1] <= ram_data[7:0];
				next_state <= S0;
			end
			ADD: begin
				Register[ram_data[1:0]] <= alu_out;
				next_state <= S0; 
			end
			SUB: begin
				Register[ram_data[1:0]] <= alu_out;
				next_state <= S0;
				
			end
			STORE_A: begin
				ram_read_en <= 1'b0;
				ram_write_en <= 1'b1;
				next_state = S0;
			end

			default: next_state = S0;
		endcase
	end

	default: begin
		next_state <= S0;
		ram_read_en  <= 1'b0;
		ram_write_en <= 1'b0;
		ram_address <= 4'b0000;
		opcode <= NOP;
	end
endcase
end

endmodule
