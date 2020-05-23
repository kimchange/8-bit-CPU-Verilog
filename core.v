`timescale 1ns / 1ps
module core(clk, rst);	// Top-level entity(except core-tb)
input clk, rst;

wire ram_read_en, ram_write_en;
wire overflow, zero, negative;

wire[7:0] ram_data;
wire[7:0] alu_in_A, alu_in_B, alu_out;
wire[3:0] opcode, ram_address;

//module alu(opcode, alu_in_A, alu_in_B, alu_out, overflow, zero, negative);
alu ALU(.opcode(opcode), .alu_in_A(alu_in_A), .alu_in_B(alu_in_B), .alu_out(alu_out), .overflow(overflow), .zero(zero), .negative(negative));

//module ram(ram_data, ram_read_en, ram_write_en, ram_address);
ram RAM(.ram_data(ram_data), .ram_read_en(ram_read_en), .ram_write_en(ram_write_en), .ram_address(ram_address));


//module control_unit(clk, rst, ram_data, ram_read_en, ram_write_en, ram_address, opcode, alu_in_A, alu_in_B, alu_out, overflow, zero, negative);
control_unit CONTROL_UNIT(.clk(clk), 
					.rst(rst), 
					.ram_data(ram_data), 
					.ram_read_en(ram_read_en), 
					.ram_write_en(ram_write_en), 
					.ram_address(ram_address), 
					.opcode(opcode), 
					.alu_in_A(alu_in_A), 
					.alu_in_B(alu_in_B), 
					.alu_out(alu_out), 
					.overflow(overflow), 
					.zero(zero), 
					.negative(negative)
					);
					

endmodule
