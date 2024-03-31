`timescale 1ns/1ps

module async_fifo_tb;
reg wr_clock,rd_clock,areset,wr_enable,rd_enable;
reg [3:0] input_data;
wire empty,full;
wire [3:0] output_data;
integer i;

//instantiating the DUT 
AsynchronousFIFO async_fifo(input_data,wr_clock,rd_clock,areset,wr_enable,rd_enable,full,empty,output_data);

//---clock initialization and generation------
initial begin
	wr_clock<=0; 
	rd_clock<=0;
end
always@(*) #5 wr_clock<=~wr_clock; //generation of write clock with 10ns period
always@(*) #10 rd_clock<=~rd_clock; //generation of read clock with 20ns period
	
//---input declaration--------
initial begin
	areset<=1;wr_enable<=0;rd_enable<=0;
	#20 areset<=0; wr_enable<=1;rd_enable<=0;
	#80 wr_enable<=0;rd_enable<=1;
	#30 wr_enable<=1;rd_enable<=1;
	#50 wr_enable<=1;rd_enable<=0;
	#100 wr_enable<=0;rd_enable<=1;
	#50 wr_enable<=1;rd_enable<=0;
end
initial begin
	input_data<= 4'b0000;
	repeat(3)
	for(i=0; i<16; i=i+1)
			#10 input_data<=i; //assigning i value to input in a loop with delay of 10ns
end

endmodule
