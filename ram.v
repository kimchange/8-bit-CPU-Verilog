`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////
module ram(ram_data, ram_read_en, ram_write_en, ram_address);

input ram_read_en, ram_write_en;
input [3:0] ram_address;

inout [7:0] ram_data;

reg [7:0] ram[0:15];

//仅做仿真时观察波形使用：begin
wire [7:0] ram_13; 
assign ram_13 = ram[13];
//仅做仿真时观察波形使用：end

// //第一个程序，计算机速成课episode 7
// //3+14 = 17
// initial 
// 	begin
// 		ram[0] = 8'b0010_1110; // LOAD_A 14
// 		ram[1] = 8'b0001_1111; // LOAD_B 15
// 		ram[2] = 8'b1000_0100; // ADD B A
// 		ram[3] = 8'b0100_1101; // STORE_A 13
// 		ram[4] = 8'b0000_0000;
// 		ram[5] = 8'b0000_0000;
// 		ram[6] = 8'b0000_0000;
// 		ram[7] = 8'b0000_0000;
// 		ram[8] = 8'b0000_0000;
// 		ram[9] = 8'b0000_0000;
// 		ram[10]= 8'b0000_0000;
// 		ram[11]= 8'b0000_0000;
// 		ram[12]= 8'b0000_0000;
// 		ram[13]= 8'b0000_0000;
// 		ram[14]= 8'b0000_0011; // 3
// 		ram[15]= 8'b0000_1110; // 14
// 	end

// //第二个程序，计算机速成课episode 8
// //1+1,2+1,...
// initial 
// 	begin
// 		ram[0] = 8'b0010_1110; // LOAD_A 14
// 		ram[1] = 8'b0001_1111; // LOAD_B 15
// 		ram[2] = 8'b1000_0100; // ADD B A
// 		ram[3] = 8'b0100_1101; // STORE_A 13
// 		ram[4] = 8'b1010_0010; // JUMP 2
// 		ram[5] = 8'b0000_0000;
// 		ram[6] = 8'b0000_0000;
// 		ram[7] = 8'b0000_0000;
// 		ram[8] = 8'b0000_0000;
// 		ram[9] = 8'b0000_0000;
// 		ram[10]= 8'b0000_0000;
// 		ram[11]= 8'b0000_0000;
// 		ram[12]= 8'b0000_0000;
// 		ram[13]= 8'b0000_0000;
// 		ram[14]= 8'b0000_0001; // 1
// 		ram[15]= 8'b0000_0001; // 1
// 	end

// 第三个程序，计算机速成课episode 8
// 11 mod 5 == 1
initial 
	begin
		ram[0] = 8'b0010_1110; // LOAD_A 14
		ram[1] = 8'b0001_1111; // LOAD_B 15
		ram[2] = 8'b1001_0100; // SUB B A
		ram[3] = 8'b1011_0101; // JUMP_NEG 5
		ram[4] = 8'b1010_0010; // JUMP 2
		ram[5] = 8'b1000_0100; // ADD B A
		ram[6] = 8'b0100_1101; // STORE_A 13
		ram[7] = 8'b0000_0000; // HALT
		ram[8] = 8'b0000_0000;
		ram[9] = 8'b0000_0000;
		ram[10]= 8'b0000_0000;
		ram[11]= 8'b0000_0000;
		ram[12]= 8'b0000_0000;
		ram[13]= 8'b0000_0000;
		ram[14]= 8'b0000_1011; // 11
		ram[15]= 8'b0000_0101; // 5
	end


assign ram_data = (ram_read_en)? ram[ram_address]:8'hzz;		// read data from RAM

//尝试了always @(posedge ram_write_en) //失败，发现赋值结果为高阻态
always @(ram_write_en or ram_data) begin	// write data to RAM
	if (ram_write_en) ram[ram_address] <= ram_data;
end

endmodule
