`timescale  1ns/1ps
module Pro(HWRITE,Data,Address,result,A,B,Command,Clk,HSIZE,HBURST,HREADY,HRST,HREQ,HACK,In_Add_Reg,In_Add_Out,Burst,Size);
//Control Signals
output reg HWRITE,HACK;
output reg [1:0]HSIZE,HBURST;
input HREADY,HRST,HREQ;
input [1:0]Burst,Size;
output reg [31:0]Address;
output reg [31:0]result;
input [31:0]A,B,In_Add_Reg,In_Add_Out;
inout [31:0]Data;
input [1:0]Command;
input Clk;
reg [31:0]Mem[0:63];
reg [1:0] OP,Temp_Burst,Temp_Size;
reg [31:0]Tempo,Add_Reg,Temp_Out,Temp_Reg;
reg hold;
integer i,s;
assign Data = (OP===2'b10 || (OP===2'b00&&Address[31:4]===28'd555)) ? Tempo : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
initial 
begin
i=50;
s=50;
hold=1'b0;
HSIZE<=1'bz;
HBURST<=1'bz;
Address<=32'hzzzzzzzz;
result<=1'bz;
HACK<=0;
hold<=1'b0;
HWRITE<=1'bz;
OP<=2'bzz;
Add_Reg<=32'hzzzzzz;
$readmemh("D:/Instructions.txt",Mem);
end
always @(posedge Clk && hold===1'b0 && HREADY!=1'b1)
begin
if(HRST===1'b1)
begin
@(negedge Clk);
HSIZE<=1'bz;
HBURST<=1'bz;
Address<=32'hzzzzzzzz;
result<=32'hzzzzzzzz;
HACK<=0;
hold<=1'b0;
HWRITE<=1'bz;
Add_Reg<=32'hzzzzzz;
end

else
begin
if(Command===2'b11)
begin
result=Mem[A]+Mem[B];

end
else if(Command===2'b00)
begin
OP=2'b00;
Temp_Out=In_Add_Out;
Temp_Reg=In_Add_Reg;
Temp_Burst=Burst;
Temp_Size=Size;
@(negedge Clk);
if(~(i<s) ||(i===50)|| (s===1))
begin
Address=Temp_Out;
Add_Reg=Temp_Reg;
HSIZE=Temp_Size;
if(Temp_Burst===2'b00)begin s=1; end
else if(Temp_Burst===2'b01)begin s=2; end
else if(Temp_Burst===2'b10)begin s=4; end
else if(Temp_Burst===2'b11)begin s=8; end
HBURST=Temp_Burst;
Tempo=Mem[Add_Reg];
i=1;
HWRITE=0;
end
end

else if(Command===2'b01)
begin
Temp_Out=In_Add_Out;
Temp_Reg=In_Add_Reg;
Temp_Burst=Burst;
Temp_Size=Size;
//load
@(negedge Clk);
Address=Temp_Out;
Add_Reg=Temp_Reg;
HWRITE=1'b1;
HSIZE=Temp_Size;
if(Temp_Burst===2'b00)begin s=1; end
else if(Temp_Burst===2'b01)begin s=2; end
else if(Temp_Burst===2'b10)begin s=4; end
else if(Temp_Burst===2'b11)begin s=8; end
HBURST=Temp_Burst;
OP=2'b01;
end

else if(Command===2'b10)
begin
Temp_Out=In_Add_Out;
Temp_Reg=In_Add_Reg;
Temp_Burst=Burst;
Temp_Size=Size;
//store
@(negedge Clk);
Address=Temp_Out;
Add_Reg=Temp_Reg;
HWRITE=1'b0;
HSIZE=Temp_Size;
if(Temp_Burst===2'b00)begin s=1; end
else if(Temp_Burst===2'b01)begin s=2; end
else if(Temp_Burst===2'b10)begin s=4; end
else if(Temp_Burst===2'b11)begin s=8; end
HBURST=Temp_Burst;
OP=2'b10;
Tempo=Mem[Add_Reg];
@(posedge HREADY);
end

if(HREQ===1'b1)
begin
@(negedge Clk);
HACK<=1'b1;
hold<=1'b1;
HSIZE=2'bzz;
HBURST=2'bzz;
Address=32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
HWRITE<=1'bz;
end

end
end

always @(posedge HACK)
begin
@(negedge HREQ)
HACK=1'b0;
hold=1'b0;
end


always@(negedge Clk)
begin
if(Command==2'b00 && Address[31:4]===28'd555 && hold===1'b0 &&i<s)
begin
Tempo=Mem[i+Add_Reg];
Address=Address+1;
i=i+1;
end
else if (HREADY!==1'b1)
begin
Address=32'hzzzzzzzz;
Tempo=32'hzzzzzzzz;
end
end

always @(posedge HREADY && HREADY==1'b1 && hold===1'b0)
begin
if(OP===2'b01)//load
begin
for(i=0;i<s;i=i+1)
begin
@(posedge Clk)
Address=Address+1;
Mem[i+Add_Reg]<=Data;
end
Address=32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
@(negedge Clk)
begin
Address=32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
end
end
else if(OP===2'b10)//store
begin
for(i=1;i<s;i=i+1)
begin
@(negedge Clk)
Address=Address+1;
Tempo=Mem[i+Add_Reg];
end
@(negedge Clk)
begin
Address=32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
end
end
OP=2'bzz;
end
endmodule



module Ram(control ,Data ,clk,chipselect,burst,size,status,address);
reg [7:0] MEMORY [0:1023];
reg [31:0] STATUS;
input[1:0] burst;
input clk; 
input chipselect;
//input  read,write;
input[1:0] size;
input control;
inout [31:0]Data;
input [28:0]address;
output status;
reg [31:0]Tempo;
integer f,i,s,flag,step,j;
assign status = STATUS[0];
assign Data = (control===1'b1 && chipselect) ? Tempo : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
initial 
begin
flag=0;
STATUS[0]=1'bz;
Tempo=32'hzzzzzzzz;
$readmemb("D:/Ram_Code.txt",MEMORY);
end
//if we want to write or read in the io device we make chip select
always@(posedge clk && status!=1'b1)
begin

if (chipselect)//chip selc.
begin

if(control==1)//read
begin
if(burst==2'b00 && flag===0) begin s=1; end
else if(burst==2'b01 && flag===0) begin s=2; end
else if(burst==2'b10 && flag===0) begin s=4; end
else if(burst==2'b11 && flag===0) begin s=8; end
if(size==2'b00 && flag===0) begin step=8; end
else if(size==2'b01 && flag===0) begin step=16; end
else if(size==2'b10 && flag===0) begin step=32; end
 end
else if(control==0)//write
begin
if(burst==2'b00 && flag===0) begin s=1; end
else if(burst==2'b01 && flag===0) begin s=2; end
else if(burst==2'b10 && flag===0) begin s=4; end
else if(burst==2'b11 && flag===0) begin s=8; end
if(size==2'b00 && flag===0) begin step=8; end
else if(size==2'b01 && flag===0) begin step=16; end
else if(size==2'b10 && flag===0) begin step=32; end
 end
flag=1;
end
end
//begin
// f = $fopen("D:/ReadAddress/DMemory.txt");
//      for (i = 0; i<1024; i=i+4)
//   $fwrite(f,"%0d:\t%h\t%h\t%h\t%h\n",4*i,DMem[i],DMem[i+1],DMem[i+2],DMem[i+3]);
//      $fclose(f) ;
//end
always @(flag===1 && chipselect===1'b1)
begin
if(control==1)//read
begin
Tempo=32'hzzzzzzzz;
for(i=0;i<s;i=i+1)
	begin
	@(negedge clk);
	STATUS[0]=1;
	if(step==8)
		begin
		Tempo<={{24{1'b0}},MEMORY[address]};
		end
	else if(step==16)
		begin
		Tempo<={{16{1'b0}},MEMORY[address],MEMORY[address+1]};
		end
	else if(step==32)
		begin
		Tempo<={{0{1'b0}},MEMORY[address],MEMORY[address+1],MEMORY[address+2],MEMORY[address+3]};
		end
	end
@(posedge clk)
begin
#5
STATUS[0]=1'bz;
Tempo=32'hzzzzzzzz;
end
end
else if(control==0)
begin//write
	STATUS[0]=1;
 for(i=0;i<s;i=i+1)
begin
@(posedge clk);
for(j=0;j<(step/8);j=j+1)
begin
MEMORY[j+address]<=Data[j+:8];
end
end
#5
STATUS[0]=1'bz;
end
flag=0;
end
endmodule

module IoDevice(control ,Data ,clk,chipselect,burst,size,status,address);
reg [7:0] MEMORY [0:32];
reg [31:0] STATUS;
input[1:0] burst;
input clk; 
input chipselect;
//input  read,write;
input[1:0] size;
input control;
inout [31:0]Data;
input [2:0]address;
output status;
reg [31:0]Tempo;
integer f,i,s,flag,step,j;
assign status = STATUS[0];
assign Data = (control===1'b1 && chipselect && status===1) ? Tempo : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
initial 
begin
flag=0;
STATUS[0]=1'bz;
Tempo=32'hzzzzzzzz;
$readmemb("D:/Machine_Code.txt",MEMORY);
i=0;
end
//if we want to write or read in the io device we make chip select
always@(posedge clk && status!=1'b1)
begin

if (chipselect)//chip selc.
begin

if(control==1)//read
begin
if(burst==2'b00 && flag===0) begin s=1; end
else if(burst==2'b01 && flag===0) begin s=2; end
else if(burst==2'b10 && flag===0) begin s=4; end
else if(burst==2'b11 && flag===0) begin s=8; end
if(size==2'b00 && flag===0) begin step=8; end
else if(size==2'b01 && flag===0) begin step=16; end
else if(size==2'b10 && flag===0) begin step=32; end
 end
else if(control==0)//write
begin
if(burst==2'b00 && flag===0) begin s=1; end
else if(burst==2'b01 && flag===0) begin s=2; end
else if(burst==2'b10 && flag===0) begin s=4; end
else if(burst==2'b11 && flag===0) begin s=8; end
if(size==2'b00 && flag===0) begin step=8; end
else if(size==2'b01 && flag===0) begin step=16; end
else if(size==2'b10 && flag===0) begin step=32; end
 end
flag=1;
end
end
//begin
// f = $fopen("D:/ReadAddress/DMemory.txt");
//      for (i = 0; i<1024; i=i+4)
//   $fwrite(f,"%0d:\t%h\t%h\t%h\t%h\n",4*i,DMem[i],DMem[i+1],DMem[i+2],DMem[i+3]);
//      $fclose(f) ;
//end
always @(flag===1 && chipselect===1'b1)
begin
if(control==1)//read
begin
Tempo=32'hzzzzzzzz;
for(i=0;i<s;i=i+1)
	begin
	@(negedge clk);
	STATUS[0]=1;
	if(step==8)
		begin
		Tempo<={{24{1'b0}},MEMORY[address]};
		end
	else if(step==16)
		begin
		Tempo<={{16{1'b0}},MEMORY[address],MEMORY[address+1]};
		end
	else if(step==32)
		begin
		Tempo<={{0{1'b0}},MEMORY[address],MEMORY[address+1],MEMORY[address+2],MEMORY[address+3]};
		end
	end
@(posedge clk)
begin
#5
STATUS[0]=1'bz;
Tempo=32'hzzzzzzzz;
end
end
else if(control==0)
begin//write
STATUS[0]=1;
 for(i=0;i<s;i=i+1)
begin
@(posedge clk);
for(j=0;j<(step/8);j=j+1)
begin
MEMORY[j+address]<=Data[j+:8];
end
end
STATUS[0]=1'bz;
end
flag=0;
end
endmodule

module Decoder_29Bit(In_Address,Dev_Address,Enable);
output reg Enable;
input [28:0] Dev_Address,In_Address;
integer flag;
initial
begin
Enable=1'b0;
flag=0;
end

always@(In_Address)
begin
if(In_Address===Dev_Address)
begin
Enable=1'b1;
flag=1;
end
else
begin
if (flag===1)
begin
#10;
end
Enable=1'b0;
flag=0;
end
end

endmodule
module Decoder_28Bit(In_Address,Dev_Address,Enable);
output reg Enable;
input [27:0] Dev_Address,In_Address;
integer flag;
initial
begin
Enable=1'b0;
flag=0;
end

always@(In_Address)
begin
if(In_Address===Dev_Address)
begin
Enable=1'b1;
flag=1;
end
else
begin
if(flag===1)
begin
#10;
end
Enable=1'b0;
flag=0;
end
end

endmodule
module Decoder_3Bit(In_Address,Dev_Address,Enable);
output reg Enable;
input [2:0] Dev_Address,In_Address;
integer flag;
initial
begin
Enable=1'b0;
flag=0;
end

always@(In_Address)
begin
if(In_Address==Dev_Address)
begin
Enable=1'b1;
flag=1;
end
else
begin
if(flag==1)
begin
#10;
end
Enable=1'b0;
flag=0;
end
end

endmodule





module clk(Clk);
output reg Clk;
always
begin
Clk=0;
#5;
Clk=1;
#5;
end
endmodule

module FIFO(TempR, TempW, IntBus, IntBusOut,CLR, CLK);
	input TempR, TempW, CLR, CLK;
	input [31:0] IntBus;
	output reg [31:0] IntBusOut;
	reg [31:0] Temp [0:7];
	integer i, ptr = 0;

	initial 
	begin
		for(i=0; i<8; i=i+1)
			Temp[i] = 32'd0;
	end
	
	always @(posedge CLR)
	begin
		ptr =0;
		for(i=0; i<8; i=i+1)
			Temp[i] = 32'd0;
	end

	always @(negedge CLK)
	begin
		IntBusOut = 32'dz;
		if(TempW) begin
			IntBusOut = Temp[0];
			for(i =0; i < 7; i = i+1) Temp[i] = Temp[i+1];
			ptr = ptr -1;
			if(ptr == -1) ptr =7;
		end
		else if(TempR) begin 
			Temp[ptr] <= IntBus; 
			ptr = ptr+1;
			if(ptr == 8) begin ptr =0; end
		end
	end
	
endmodule

module HReqLogic(TC,HReqFlag);
	input [3:0] TC;
	output HReqFlag;

	or(w1, TC[0],TC[1]);
	or(w2, TC[0],TC[2]);
	or(w3, TC[0],TC[3]);
	or(w4, TC[1],TC[2]);
	or(w5, TC[1],TC[3]);
	or(w6, TC[2],TC[3]);

	nand(HReqFlag, w1,w2,w3,w4,w5,w6);

endmodule

module CommandControl(CS, HAck,A, RW, TempR, TempW, StatusW, SingleModeR, AllModeR, RequestR, SingleMaskR, AllMaskR, MaskCLR, CommandR, DBufR, DBufW,CAddressR, CAddressW, CWordCountR, CWordCountW, CLR);

	input [3:0] A;
	input RW, CS, HAck;
	output reg TempR, TempW, StatusW, SingleModeR,AllModeR, RequestR, SingleMaskR, AllMaskR, MaskCLR, CommandR, DBufR, DBufW, CAddressR, CAddressW, CWordCountR, CWordCountW, CLR;

	always @(A,RW,CS)
	if(CS & ~HAck)
	begin
	CLR =0;

	case({A, RW})
		//Current Address & Word Count 

		0: // Ch0 Base & Current Address Write
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=1;
			CAddressR   <=1;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		1: // Ch0 Current Address Read
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=1;
			DBufW       <=0;
			CAddressR   <=0;
			CAddressW   <=1;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		2: // Ch0 Base & Current WordCount Write
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=1;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=1;
			CWordCountW <=0;
			end
		3: // Ch0 Current WordCount Read
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=1;
			DBufW       <=0;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=1;
			end
		4:  // Ch1 Base & Current Address Write
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=1;
			CAddressR   <=1;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		5:  // Ch1 Current Address Read
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=1;
			DBufW       <=0;
			CAddressR   <=0;
			CAddressW   <=1;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		6:  // Ch1 Base & Current WordCount Write
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=1;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=1;
			CWordCountW <=0;
			end
		7:  // Ch1 Current WordCount Read
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=1;
			DBufW       <=0;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=1;
			end
		8: // Ch2 Base & Current Address Write
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=1;
			CAddressR   <=1;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		9:  // Ch2 Current Address Read
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=1;
			DBufW       <=0;
			CAddressR   <=0;
			CAddressW   <=1;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		10:  // Ch2 Base & Current WordCount Write
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=1;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=1;
			CWordCountW <=0;
			end
		11:  // Ch2 Current WordCount Read
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=1;
			DBufW       <=0;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=1;
			end
		12: // Ch3 Base & Current Address Write
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=1;
			CAddressR   <=1;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		13:  // Ch3 Current Address Read
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=1;
			DBufW       <=0;
			CAddressR   <=0;
			CAddressW   <=1;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		14:  // Ch3 Base & Current WordCount Write
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=1;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=1;
			CWordCountW <=0;
			end
		15:  // Ch2 Current WordCount Read
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=1;
			DBufW       <=0;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=1;
			end
		// Control Regesters

		16: //Write Command Register
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=1;
			DBufR       <=0;
			DBufW       <=1;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		17: //Read Status Register
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=1;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=1;
			DBufW       <=0;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		18: //Write Request Register
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=1;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=1;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		20: //Write Single Mask Register Bit
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=1;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=1;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		22: //Write Single Mode Register
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=1;
			AllModeR   <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=1;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		24: //Write All Mode Register
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=1;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=1;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		26: // Master Clear
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=0;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			CLR         =1;
			end
		27: // Read Temporary Register
			begin
			TempR       <=0;
			TempW       <=1;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=1;
			DBufW       <=0;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		28: // Clear Mask Register
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=1;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=0;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		30: // Write All Mask Register Bits
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=1;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=1;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			end
		default: //Clear
			begin
			TempR       <=0;
			TempW       <=0;
			StatusW     <=0;
			SingleModeR <=0;
			AllModeR    <=0;
			RequestR    <=0;
			SingleMaskR <=0;
			AllMaskR    <=0;
			MaskCLR     <=0;
			CommandR    <=0;
			DBufR       <=0;
			DBufW       <=0;
			CAddressR   <=0;
			CAddressW   <=0;
			CWordCountR <=0;
			CWordCountW <=0;
			end
	endcase
	end
	else
	begin // Clear
		TempR       <=0;
		TempW       <=0;
		StatusW     <=0;
		SingleModeR <=0;
		AllModeR    <=0;
		RequestR    <=0;
		SingleMaskR <=0;
		AllMaskR    <=0;
		MaskCLR     <=0;
		CommandR    <=0;
		DBufR       <=0;
		DBufW       <=0;
		CAddressR   <=0;
		CAddressW   <=0;
		CWordCountR <=0;
		CWordCountW <=0;
	end
endmodule

module DMA(MSAddress, LSA, Data, RST, CS, RDY, Burst, Size, RW, DReq, DAck, HReq, HAck, CLK, Pin5);
	
	//Address & Data Bus
	output wire [27:0] MSAddress;
	inout wire  [3:0] LSA;
	wire [3:0] LSAddress;
	inout wire [31:0] Data;

	input Pin5;

	//Control Bus
	inout wire RW;
	inout wire [1:0] Burst, Size;
	input RST, CS, RDY, CLK;
	wire CLR;
	reg RWWire;
	reg [1:0] BurstWire, SizeWire;
	reg RWW =0, BurstW=0, SizeW=0;

	assign RW = (RWW)? RWWire: 1'bz;
	assign Burst =(BurstW)? BurstWire: 2'bzz;
	assign Size =(SizeW)? SizeWire: 2'bzz;

	//Request & Acknowledge
	input [3:0] DReq;
	output reg [3:0] DAck = 4'b0000;
	input HAck;
	output HReq;
	reg [1:0] StatusPtr =2'b00;

	//Counter Registers (Address & WordCount)
	reg [31:0] BaseAddress [0:3];
	reg [31:0] BaseWordCount [0:3];
	reg [31:0] CurrentAddress [0:3];
	reg signed [31:0] CurrentWordCount [0:3];
	wire [31:0] Decrementor;
	reg [31:0] IncDecrementor;

	// Internal Bus and Control Registers
	wire [7:0] Status;
	reg [11:0] Mode;
	reg [3:0] Request;
	reg [3:0] Mask;
	reg [13:0] Command;
	reg T1, T2;
	reg [31:0] IntBus;
	wire [31:0] IntBusOut;
	wire TempR, TempW, StatusW, SingleModeR, RequestR, SingleMaskR, AllModeR, AllMaskR, MaskCLR, CommandR, DBufR, DBufW, CAddressR, CAddressW, CWordCountR, CWordCountW;
	reg TempR_=0,TempW_=0,DBufR_=0,DBufW_=0;
	
	assign LSAddress = LSA;

	FIFO Temporary(TempR | TempR_, TempW | TempW_,IntBus, IntBusOut,CLR | RST, CLK);

	CommandControl CC(CS,HAck, LSAddress, RW, TempR, TempW, StatusW, SingleModeR, AllModeR, RequestR, SingleMaskR, AllMaskR, MaskCLR, CommandR, DBufR, DBufW,CAddressR, CAddressW, CWordCountR, CWordCountW, CLR);
	

	//initialise Regesters
	integer i;
	initial 
	begin
		for(i =0; i< 4; i=i+1)
			Mode = 12'd0;
		Request = 4'd0;
		Mask = 4'd0;
		Command = 14'd0;
		for(i =0; i< 4; i=i+1)
		begin
			BaseAddress[i] = 32'd0;
			BaseWordCount[i] = 32'hffffffff;
			CurrentAddress[i] = 32'd0;
			CurrentWordCount[i] = 32'hffffffff;
		end
	end


	//Decrementor & IncDecrementor Wires

	reg [1:0] Channel=0; //Control Signal
	reg ABufW =0;        //Control Signal
	reg CurrentDecR =0;  //Control Signal

	assign Decrementor = CurrentWordCount[Channel] - 1;
	always @(posedge CLK)
	begin
		if(T1)
		  case(Command[1:0])
			0: IncDecrementor = Mode[3*Channel + 2]? CurrentAddress[Channel] :( Mode[3*Channel + 1]? CurrentAddress[Channel]-1 : CurrentAddress[Channel]+1); // Byte
			
			1: IncDecrementor = Mode[3*Channel + 2]? CurrentAddress[Channel] :( Mode[3*Channel + 1]? CurrentAddress[Channel]-2 : CurrentAddress[Channel]+2); // HalfWord
			
			default: IncDecrementor = Mode[3*Channel + 2]? CurrentAddress[Channel] :( Mode[3*Channel + 1]? CurrentAddress[Channel]-4 : CurrentAddress[Channel]+4); // Word
		  endcase
		else if(T2)		
		  case(Command[7:6])
			0: IncDecrementor = Mode[3*Channel + 2]? CurrentAddress[Channel] :( Mode[3*Channel + 1]? CurrentAddress[Channel]-1 : CurrentAddress[Channel]+1); // Byte
			
			1: IncDecrementor = Mode[3*Channel + 2]? CurrentAddress[Channel] :( Mode[3*Channel + 1]? CurrentAddress[Channel]-2 : CurrentAddress[Channel]+2); // HalfWord
			
			default: IncDecrementor = Mode[3*Channel + 2]? CurrentAddress[Channel] :( Mode[3*Channel + 1]? CurrentAddress[Channel]-4 : CurrentAddress[Channel]+4); // Word
		  endcase
		
	end

	always @(negedge CLK)
		if(CurrentDecR)
		begin
			CurrentAddress[Channel] <= IncDecrementor;
			CurrentWordCount[Channel] <= Decrementor;
		end

	assign MSAddress = (ABufW)? CurrentAddress[Channel][31:4] : 28'dz;
	assign LSA = (ABufW)? CurrentAddress[Channel][3:0] : 4'dz;


	// Internal Control Signals
	assign Data = (DBufR)? IntBus :32'dz ;
	assign Data = (DBufR_)? IntBusOut :32'dz ;
	wire [1:0] Ch;
	assign Ch = IntBus[1:0];
	
	always @(posedge CLK)
	if(!RST)
	begin
		
		// Data to the Bus (Blocking)
		if(StatusW) IntBus = {24'd0, Status};
		if(DBufW | DBufW_) IntBus = Data;
		if(CAddressW) IntBus = CurrentAddress[LSAddress[2:1]];
		if(CWordCountW) IntBus = CurrentWordCount[LSAddress[2:1]];
		if(TempW | TempW_) IntBus = IntBusOut;

		// Data from the Bus (NonBlocking)
		if(SingleModeR) 
		begin
			Mode[3*Ch] <=  IntBus[2];
			Mode[3*Ch+1] <=  IntBus[3];
			Mode[3*Ch+2] <=  IntBus[4];
		end
		if(AllModeR) Mode <= IntBus[11:0];
		if(RequestR) Request[Ch] <= IntBus[2];
		if(SingleMaskR) Mask[Ch] <= IntBus[2];
		if(AllMaskR) Mask <= IntBus[3:0];
		if(MaskCLR) Mask <= 4'd0;
		if(CommandR) Command <= IntBus[13:0];
		if(CAddressR) 
		begin 
			BaseAddress[LSAddress[2:1]] <= IntBus; 
			CurrentAddress[LSAddress[2:1]] <=IntBus; 
		end
		if(CWordCountR)  
		begin 
			BaseWordCount[LSAddress[2:1]] <= IntBus; 
			CurrentWordCount[LSAddress[2:1]] <=IntBus; 
		end
	end

	always @(RST, CLR)
	if(RST | CLR)
	begin
		Request = 4'd0;
		Mask = 4'd0;
		Command = 14'd0;
		for(i =0; i< 4; i=i+1)
		begin
			Mode = 12'd0;
			BaseAddress[i] = 32'd0;
			BaseWordCount[i] = 32'hffffffff;
			CurrentAddress[i] = 32'd0;
			CurrentWordCount[i] = 32'hffffffff;
		end

	end


	//Priority Encoder Logic
	HReqLogic HREQL(Status[3:0], HReqFlag);
	
	assign HReq = (HReqFlag | (HAck & ~(Status[0] & Status[1] & Status[2] & Status[3])) | (Status[4] & ~Mask[0]) | (Status[5] & ~Mask[1]) | (Status[6] & ~Mask[2]) | (Status[7] & ~Mask[3])) & ~Command[12];

	always@(posedge CLK)
	if(HAck)
	begin

		if(Command[13])	// Rotating Priority (Round Robin)
		begin
			case(StatusPtr)
				0:begin
					if(Status[4])
					begin
						DAck = 4'b0001;
						@(negedge Status[4]) StatusPtr = 2'b01;
					end
					else if(Status[5])
					begin
						DAck = 4'b0010;
						@(negedge Status[5]) StatusPtr = 2'b10;
					end
					else if (Status[6])
					begin
						DAck = 4'b0100;
						@(negedge Status[6]) StatusPtr = 2'b11;
					end
					else if (Status[7])
					begin
						DAck = 4'b1000;
						@(negedge Status[7]) StatusPtr = 2'b00;
					end
					else	DAck = 4'b0000;
				end
				1:begin
					if(Status[5])
					begin
						DAck = 4'b0010;
						@(negedge Status[5]) StatusPtr = 2'b10;
					end
					else if (Status[6])
					begin
						DAck = 4'b0100;
						@(negedge Status[6]) StatusPtr = 2'b11;
					end
					else if (Status[7])
					begin
						DAck = 4'b1000;
						@(negedge Status[7]) StatusPtr = 2'b00;
					end
					else if (Status[4])
					begin
						DAck = 4'b0001;
						@(negedge Status[4]) StatusPtr = 2'b01;
					end
					else	DAck = 4'b0000;
				end
				2:begin
					if (Status[6])
					begin
						DAck = 4'b0100;
						@(negedge Status[6]) StatusPtr = 2'b11;
					end
					else if (Status[7])
					begin
						DAck = 4'b1000;
						@(negedge Status[7]) StatusPtr = 2'b00;
					end
					else if (Status[4])
					begin
						DAck = 4'b0001;
						@(negedge Status[4]) StatusPtr = 2'b01;
					end
					else if (Status[5])
					begin
						DAck = 4'b0010;
						@(negedge Status[5]) StatusPtr = 2'b10;
					end
					else	DAck = 4'b0000;
				end
				3:begin
					if (Status[7])
					begin
						DAck = 4'b1000;
						@(negedge Status[7]) StatusPtr = 2'b00;
					end
					else if (Status[4])
					begin
						DAck = 4'b0001;
						@(negedge Status[4]) StatusPtr = 2'b01;
					end
					else if (Status[5])
					begin
						DAck = 4'b0010;
						@(negedge Status[5]) StatusPtr = 2'b10;
					end
					else if (Status[6])
					begin
						DAck = 4'b0100;
						@(negedge Status[6]) StatusPtr = 2'b11;
					end
					else	DAck = 4'b0000;
				end	
			endcase
		end
		
		else		// Fixed Prority
		begin
			if(Status[4])
			begin
				DAck = 4'b0001;
			end
			else if(Status[5])
			begin
				DAck = 4'b0010;
			end
			else if (Status[6])
			begin
				DAck = 4'b0100;
			end
			else if (Status[7])
			begin
				DAck = 4'b1000;
			end
			else	DAck = 4'b0000;
		end
	end



	//Status Register Functionality
	assign Status[0] = (CurrentWordCount[0] == 32'hffffffff)? 1'b1: 1'b0;
	assign Status[1] = (CurrentWordCount[1] == 32'hffffffff)? 1'b1: 1'b0;
	assign Status[2] = (CurrentWordCount[2] == 32'hffffffff)? 1'b1: 1'b0;
	assign Status[3] = (CurrentWordCount[3] == 32'hffffffff)? 1'b1: 1'b0;
	assign Status[4] = (DReq[0] === 1'b1)? 1:0;
	assign Status[5] = (DReq[1] === 1'b1)? 1:0;
	assign Status[6] = (DReq[2] === 1'b1)? 1:0;
	assign Status[7] = (DReq[3] === 1'b1)? 1:0;



	// Active Mode -----------------------------------------------------------------------------------------------------------------------------------

	reg [3:0] RemWC=0;
	reg ReadFlag=1;
	reg [1:0] intBurst;
	reg [1:0] State = 2'b00;

	always @(posedge HAck)
	begin
		if( (Command[5:4] != Command[3:2]) && (!Status[Command[5:4]] || !Status[Command[3:2]]) )
			T1 =1;
		else	T1 =0;
		if( (Command[11:10] != Command[9:8]) && (!Status[Command[11:10]] || !Status[Command[9:8]]) )
			T2 =1;
		else	T2 =0;
		
		if(T1)
		begin
			if(CurrentWordCount[Command[5:4]] >= 7)
			begin
				intBurst = 11;
				RemWC =8;
			end
			else if(CurrentWordCount[Command[5:4]] >= 3)
			begin
				intBurst = 10;
				RemWC =4;
			end
			else if(CurrentWordCount[Command[5:4]] >= 1)
			begin
				intBurst = 01;
				RemWC =2;
			end
			else
			begin
				intBurst = 00;
				RemWC =1;
			end
		end
		else if(T2)
		begin
			if(CurrentWordCount[Command[11:10]] >= 7)
			begin
				intBurst = 11;
				RemWC =8;
			end
			else if(CurrentWordCount[Command[11:10]] >= 3)
			begin
				intBurst = 10;
				RemWC =4;
			end
			else if(CurrentWordCount[Command[11:10]] >= 1)
			begin
				intBurst = 01;
				RemWC =2;
			end
			else
			begin
				intBurst = 00;
				RemWC =1;
			end
		end
	end
	

	always @(ReadFlag)
		if(T1)
		begin
			if(ReadFlag)
			begin
				if(CurrentWordCount[Command[5:4]] >= 7)
				begin
					intBurst = 11;
					RemWC =8;
				end
				else if(CurrentWordCount[Command[5:4]] >= 3)
				begin
					intBurst = 10;
					RemWC =4;
				end
				else if(CurrentWordCount[Command[5:4]] >= 1)
				begin
					intBurst = 01;
					RemWC =2;
				end
				else
				begin
					intBurst = 00;
					RemWC =1;
				end
			end
			else
			begin
				if(CurrentWordCount[Command[3:2]] >= 7)
				begin
					intBurst = 11;
					RemWC =8;
				end
				else if(CurrentWordCount[Command[3:2]] >= 3)
				begin
					intBurst = 10;
					RemWC =4;
				end
				else if(CurrentWordCount[Command[3:2]] >= 1)
				begin
					intBurst = 01;
					RemWC =2;
				end
				else
				begin
					intBurst = 00;
					RemWC =1;
				end
			end

		end
		else if(T2)
		begin
			if(ReadFlag)
			begin
				if(CurrentWordCount[Command[11:10]] >= 7)
				begin
					intBurst = 11;
					RemWC =8;
				end
				else if(CurrentWordCount[Command[11:10]] >= 3)
				begin
					intBurst = 10;
					RemWC =4;
				end
				else if(CurrentWordCount[Command[11:10]] >= 1)
				begin
					intBurst = 01;
					RemWC =2;
				end
				else
				begin
					intBurst = 00;
					RemWC =1;
				end
			end
			else
			begin
				if(CurrentWordCount[Command[9:8]] >= 7)
				begin
					intBurst = 11;
					RemWC =8;
				end
				else if(CurrentWordCount[Command[9:8]] >= 3)
				begin
					intBurst = 10;
					RemWC =4;
				end
				else if(CurrentWordCount[Command[9:8]] >= 1)
				begin
					intBurst = 01;
					RemWC =2;
				end
				else
				begin
					intBurst = 00;
					RemWC =1;
				end
			end

		end

	always @(posedge RDY)
		if(HAck)
		begin
			if(ReadFlag)
			begin
 				CurrentDecR = 1;
				DBufW_ =1;
				TempR_ =1;
				CurrentAddress[Channel] <= IncDecrementor;
				CurrentWordCount[Channel] <= Decrementor;
				State <=(RDY !== 1'b1   )? 0 :(RemWC == 1 && Burst==0)? 2'd2:2'd1;
				if(RemWC == 1 && ABufW == 1)
				begin
					ABufW =0;
					CurrentDecR <=0;
				end
			end
			
		end
	

	always@(negedge CLK)
		if(HAck)
		begin
			if(T1)
			begin
				if(ReadFlag)				//Read
				begin
					if(State == 0)
					begin
						Channel <= Command[5:4];
						ABufW <=1;
						RWWire <=1;
						RWW <=1;
						SizeWire <= Command[1:0];
						SizeW <=1;
						BurstWire <= intBurst;
						BurstW <=1; 
						if(Burst==0)
							begin
							ABufW<=0;
							CurrentDecR <=0;
							//State<=2;
							end
						
					end
					else if(State ==1 && RDY === 1'b1)
					begin
						RemWC = RemWC-1;
						State = (RemWC == 1)? 2'd2: 2'd1;
						if(RemWC == 1)
						begin
							ABufW =0;
							CurrentDecR =0;
						end
					end
					else if(State ==2)
					begin
						DBufW_ = 0;
						TempR_ = 0;
						ABufW=0; //asthbal
						if(Burst==0)
							begin
							RemWC = RemWC-1;
							ABufW=0;
							CurrentDecR =0;
							end
						else
							begin
							RemWC = RemWC-1;
							end
						//RemWC = RemWC-1;
						RWW =0;
						SizeW =0;
						BurstW=0;
						ReadFlag =0;
						State = 2'd0;
											
					end
				end
				else if(CurrentWordCount[Command[3:2]] >= CurrentWordCount[Command[5:4]])	//Write
				begin
					if(State == 0)
					begin
						CurrentDecR <= 1;
						Channel <= Command[3:2];
						ABufW <=1;
						RWWire <=0;
						RWW <=1;
						SizeWire <= Command[1:0];
						SizeW <=1;
						BurstWire <= intBurst;
						BurstW <=1;
						DBufR_ <=1;
						TempW_ <=1;
						//RemWC =(RDY !== 1'b1)? RemWC: RemWC-1;
						State <=(RDY !== 1'b1)? 0 :(RemWC == 0)? 2:1;
						if(RemWC == 1 && ABufW == 1)
						begin
							ABufW <=0;
							TempW_ <= 0;
							CurrentDecR <=0;
						end
						RemWC =(RDY !== 1'b1)? RemWC: RemWC-1;
					end
					else if(State ==1 &&   RDY === 1'b1)
					begin
						RemWC = RemWC-1;
						State = (RemWC == 0)? 2'd2: 2'd1;
						if(RemWC == 0)
						begin
							ABufW =0;
							TempW_ = 0;
							CurrentDecR =0;
						end
					end
					else if(State ==2 )
					begin
						TempW_ = 0;
						ABufW =0;
						CurrentDecR =0;
						DBufR_ = 0;
						RemWC = RemWC-1;
						RWW =0;
						SizeW =0;
						BurstW=0;
						ReadFlag =1;
						State = 2'd0;
						if(Status[Command[5:4]] && Status[Command[3:2]])
							T1 =0;
					end
				end
			end
			else if(T2)
			begin
				if(ReadFlag)				//Read
				begin
					if(State == 0)
					begin
						Channel = Command[11:10];
						ABufW <=1;
						RWWire <=1;
						RWW <=1;
						SizeWire <= Command[7:6];
						SizeW <=1;
						BurstWire <= intBurst;
						BurstW <=1;
						State <=(~RDY)? 0 :(RemWC == 1)? 2:1;
						if(RemWC == 1 && ABufW == 1)
						begin
							ABufW <=0;
							CurrentDecR <=0;
						end
					end
					else if(State ==1 && RDY)
					begin
						RemWC = RemWC-1;
						State = (RemWC == 1)? 2'd2: 2'd1;
						if(RemWC == 1)
						begin
							ABufW =0;
							CurrentDecR =0;
						end
					end
					else if(State ==2 && RDY)
					begin
						DBufW_ = 0;
						TempR_ = 0;
						RemWC = RemWC-1;
						RWW =0;
						SizeW =0;
						BurstW=0;
						ReadFlag =0;
						State = 2'd0;
					end
				end
				else if(CurrentWordCount[Command[11:10]] <= CurrentWordCount[Command[9:8]])	//Write
				begin
					if(State == 0)
					begin
						CurrentDecR <= 1;
						Channel <= Command[9:8];
						ABufW <=1;
						RWWire <=0;
						RWW <=1;
						SizeWire <= Command[7:6];
						SizeW <=1;
						BurstWire <= intBurst;
						BurstW <=1;
						DBufR_ <=1;
						TempW_ <=1;
						State <=(~RDY)? 0 :(RemWC == 0)? 2:1;
						if(RemWC == 1 && ABufW == 1)
						begin
							TempW_ <= 0;
							ABufW <=0;
							CurrentDecR <=0;
						end
					end
					else if(State ==1 && RDY)
					begin
						RemWC = RemWC-1;
						State = (RemWC == 0)? 2'd2: 2'd1;
						if(RemWC == 0)
						begin
							TempW_ = 0;
							ABufW =0;
							CurrentDecR =0;
						end
					end
					else if(State ==2 && RDY)
					begin
						TempW_ = 0;
						ABufW =0;
						CurrentDecR =0;
						DBufR_ = 0;
						RemWC = RemWC-1;
						RWW =0;
						SizeW =0;
						BurstW=0;
						ReadFlag =1;
						State = 2'd0;
						if(Status[Command[11:10]] && Status[Command[9:8]])
							T2 =0;
					end
				end
			end
			
		end


	//AutoInitialozation
	always @(negedge HAck)
	begin
		for(i=0; i<4; i = i+1)
			if(Mode[3*i])
			begin
				CurrentAddress[i] <= BaseAddress[i];
				CurrentWordCount[i] <= BaseWordCount[i];
			end
	end
	

endmodule



module TB_DJ;
reg HRST,Pin5;
reg [1:0]Burst,Size;
reg [31:0]A,B,In_Add_Reg,In_Add_Out;
reg [1:0]Command;
wire [31:0]Data,result;
wire Clk,HREADY,CS,HREQ,HACK;
wire [31:0]Address;
wire [1:0]HSIZE,HBURST;
reg [3:0] DReq;
wire [3:0] DAck;
integer j,file;
Pro Dj1(HWRITE,Data,Address,result,A,B,Command,Clk,HSIZE,HBURST,HREADY,HRST,HREQ,HACK,In_Add_Reg,In_Add_Out,Burst,Size);
Ram Dj2(HWRITE ,Data ,Clk,chipselect_1,HBURST,HSIZE,HREADY,Address[28:0]);
IoDevice Dj3(HWRITE ,Data ,Clk,chipselect_2,HBURST,HSIZE,HREADY,Address[2:0]);
IoDevice Dj4(HWRITE ,Data ,Clk,chipselect_3,HBURST,HSIZE,HREADY,Address[2:0]);
Decoder_29Bit Dj5(Address[31:3],29'd1024,chipselect_2);
Decoder_3Bit Dj6(Address[31:29],3'd5,chipselect_1);
Decoder_29Bit Dj7(Address[31:3],29'd512,chipselect_3);
Decoder_28Bit Pierre(Address[31:4],28'd555,CS);
DMA Pierre_Girguis(Address[31:4], Address[3:0], Data, HRST, CS, HREADY, HBURST, HSIZE, HWRITE, DReq, DAck, HREQ, HACK, Clk, Pin5);
clk Dj8(Clk);


initial
begin
///////NorMal Usage////////

DReq=4'b0000;
In_Add_Reg=32'hzzzzzzzz;
In_Add_Out=32'hzzzzzzzz;
A=32'd10;
B=32'd11;
HRST=1'b1;
Command<=2'bzz;
Pin5=1;
file=$fopen("D:/Signals.txt");
#20;
HRST=0;
@(negedge Clk)
for(j=0;j<=2;j=j+1)
begin
@(negedge Clk)
Command=2'b01;
In_Add_Reg=32'd15+(j*8);
In_Add_Out[31:29]=3'd5;
In_Add_Out[28:0]=29'd0;
Burst=2'b11;
Size=2'b10;
@(negedge HREADY);
end
Command=2'b11;
@(posedge Clk)
for(j=0;j<=2;j=j+1)
begin
In_Add_Reg=32'd15+(j*8);
@(negedge Clk)
Command=2'b10;
In_Add_Out[31:29]=3'd5;
In_Add_Out[28:0]=29'd0;
Burst=2'b11;
Size=2'b10;
@(negedge HREADY);
end

Command=2'b11;
@(negedge Clk)
Command=2'b01;
In_Add_Reg=32'd15;
In_Add_Out[31:29]=3'd5;
In_Add_Out[28:0]=29'd0;
Burst=2'b01;
Size=2'b10;

@(negedge HREADY)
Command=2'b11;
@(negedge Clk)
Command=2'b10;
In_Add_Reg=32'd15;
In_Add_Out[31:29]=3'd5;
In_Add_Out[28:0]=29'd0;
Burst=2'b01;
Size=2'b10;

@(negedge HREADY)
Command=2'b11;
@(negedge Clk)
Command=2'b01;
In_Add_Reg=32'd15;
In_Add_Out[31:29]=3'd5;
In_Add_Out[28:0]=29'd0;
Burst=2'b01;
Size=2'b10;

@(negedge HREADY)
Command=2'b11;
@(negedge Clk)
Command=2'b10;
In_Add_Reg=32'd15;
In_Add_Out[31:29]=3'd5;
In_Add_Out[28:0]=29'd0;
Burst=2'b01;
Size=2'b10;

@(negedge HREADY)
Command=2'b11;
@(negedge Clk)
Command=2'b01;
In_Add_Reg=32'd15;
In_Add_Out[31:29]=3'd5;
In_Add_Out[28:0]=29'd0;
Burst=2'b00;
Size=2'b10;

@(negedge HREADY)
Command=2'b11;
@(negedge Clk)
Command=2'b10;
In_Add_Reg=32'd15;
In_Add_Out[31:29]=3'd5;
In_Add_Out[28:0]=29'd0;
Burst=2'b00;
Size=2'b10;
@(negedge HREADY)
Command=2'bzz;
In_Add_Reg=32'hzzzzzzzz;
In_Add_Out=32'dz;
Burst=2'bzz;
Size=2'bzz;
///////DMA Usage/////////

@(negedge Clk)
DReq=4'b0000;
In_Add_Reg=32'hzzzzzzzz;
In_Add_Out=32'hzzzzzzzz;
HRST=1'b1;
Command<=2'bzz;
Pin5=1;
#20;
HRST=0;
//load
Command=2'b00;
Size=2'b10;
Burst=2'b00;
In_Add_Reg=0;
In_Add_Out[31:4]=28'd555;
In_Add_Out[3:0]=4'b1000;
@(negedge Clk)
#10;
In_Add_Reg=1;
In_Add_Out[31:4]=28'd555;
In_Add_Out[3:0]=4'b1100;
@(negedge Clk)
#10;
Burst=2'b11;
In_Add_Reg=2;
In_Add_Out[31:4]=28'd555;
In_Add_Out[3:0]=4'b0000;
@(negedge Clk)
#10;
Command=2'b00;
Size=2'bzz;
Burst=2'bz;
In_Add_Reg=32'hzzzzzzzz;
In_Add_Out=32'hzzzzzzzz;
#2000
begin
$finish;
end
end
always@(Clk)
begin

$fwrite(file,"Start Cycle\nData:%h\nAddress:%h\nSize:%b\nRW:%b\nBurst:%b\nCLK:%b\nReady:%b\nHAck:%b\nHReq:%b\nPin5:%b\nEnd Cycle\n\n",Data,Address,HSIZE,HWRITE,HBURST,Clk,HREADY,HACK,HREQ,Pin5);
end

endmodule
