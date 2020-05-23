`timescale 1ps / 1ps
module core_testbench; 

reg rst; 
reg clk; 

initial
	begin
    $dumpfile("test.vcd");
    $dumpvars(0,core1);
	end

initial
  begin
    clk <= 1'b0;
    # 150 ;
  repeat(9999)
  begin
    clk  = 1'b1;
    #50  clk  = 1'b0;
    #50  ;
  end
  clk  = 1'b1;
  # 50 ;
  end
initial
  begin
	  rst  = 1'b1  ;
	  # 100;
	  rst=1'b0;
	  # 9000 ;
  end
core core1(.clk(clk),.rst(rst));

initial
#1000000 $finish;
endmodule
