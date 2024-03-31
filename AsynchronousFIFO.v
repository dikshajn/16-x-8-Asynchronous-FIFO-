module AsynchronousFIFO #(parameter BUF_WIDTH=4,BUF_DEPTH=16)
		(input [BUF_WIDTH-1:0] data_in, //input data written to FIFO
		input wr_clk, //clock of clock_domain-1
		input rd_clk, //clock of clock_domain-2
		input areset, //asynchronous reset
		input wr_en, //write enable
		input rd_en, //read enable
		output full, //fifo full flag
		output empty, //fifo empty flag
		output reg [BUF_WIDTH-1:0] data_out //output data read from FIFO
		);
	
	
reg [BUF_WIDTH:0] wr_pointer,rd_pointer;//read and write pointer which points the address in fifo
wire [BUF_WIDTH:0] wr_pointer_g,rd_pointer_g; //used to convert pointer from binary to gray
reg [BUF_WIDTH:0] wr_sync1,rd_sync1,wr_sync2,rd_sync2; //internal sugnals of 2 synchronizers
wire [BUF_WIDTH:0] wr_pointer_sync,rd_pointer_sync;	//used to convert back the syncronizer data from gray to binary

		
//-----------FIFO Buffer-------------------
reg [BUF_WIDTH-1:0] fifo [0:BUF_DEPTH-1];//defining a fifo
					
//-------------Wr_pointer------------------
always @(posedge wr_clk or posedge areset) 
begin
	if(areset)
		wr_pointer <= {BUF_WIDTH{1'b0}}; //initializing write pointer to 4'b0000 using replication operator
	else 
	begin
		if(wr_en & !full)
			wr_pointer <= wr_pointer+1; //incrementing the write pointer
		else
			wr_pointer <= wr_pointer;
	end
end

//----------------rd_pointer-----------
always @(posedge rd_clk or posedge areset) 
begin
	if(areset)
		rd_pointer <= {BUF_WIDTH{1'b0}}; //initializing read pointer to 4'b0000 using replication operator
	else 
	begin
		if(rd_en & !empty)
			rd_pointer <= rd_pointer+1; //incrementing the read pointer
		else
			rd_pointer <= rd_pointer;
	end
end			
		
//----------Write into FIFO--------------
always @(posedge wr_clk)
begin
	if(wr_en & !full)
		fifo[wr_pointer[3:0]] <= data_in; //writing the data into FIFO
	else if(full)
		$display ("FIFO is full");
end

//-----------Read from FIFO---------------
always @(posedge rd_clk)
begin
	if(rd_en & !empty)
		data_out <= fifo[rd_pointer[3:0]]; //reading the data from the memory
	else if(empty)
		$display ("FIFO is empty");
end

//---------Synchronizer1(sync write pointer with read clock)------------
always @(posedge rd_clk)    //syncronizing write pointer w.r.t read clock
begin
	wr_sync1 <= wr_pointer_g; //FF1 of synchronizer1
	wr_sync2 <= wr_sync1; //FF2 of sunchronizer1
end

//---------Synchronizer2(sync read pointer with write clock)------------
always @(posedge wr_clk)    //syncronizing read pointer w.r.t write clock
begin
	rd_sync1 <= rd_pointer_g; //FF1 of synchronizer2
	rd_sync2 <= rd_sync1; //FF2 of sunchronizer2
end

//---------binary to gray conversion of read & write pointers------------
assign wr_pointer_g = wr_pointer ^ (wr_pointer>>1);
assign rd_pointer_g = rd_pointer ^ (rd_pointer>>1);

//---------gray to binary conversion of read & write sync2------------
assign wr_pointer_sync[4] = wr_sync2[4];
assign wr_pointer_sync[3] = wr_pointer_sync[4]^wr_sync2[3];
assign wr_pointer_sync[2] = wr_pointer_sync[3]^wr_sync2[2];
assign wr_pointer_sync[1] = wr_pointer_sync[2]^wr_sync2[1];
assign wr_pointer_sync[0] = wr_pointer_sync[1]^wr_sync2[0];

assign rd_pointer_sync[4] = rd_sync2[4];
assign rd_pointer_sync[3] = rd_pointer_sync[4]^wr_sync2[3];
assign rd_pointer_sync[2] = rd_pointer_sync[3]^wr_sync2[2];
assign rd_pointer_sync[1] = rd_pointer_sync[2]^wr_sync2[1];
assign rd_pointer_sync[0] = rd_pointer_sync[1]^wr_sync2[0];

//------logic for empty and full flags-----
assign empty = (rd_pointer == wr_pointer_sync) ? 1 : 0;
assign full = ({~wr_pointer[4],wr_pointer[3:0]} == rd_pointer_sync) ? 1 : 0; //why it is taken like this is written...
										//...in the "Design of Asynchronous FIFO.pdf"

endmodule
