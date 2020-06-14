module Data_Mem(RD,WD,RE,WE,CLK,RA,WA,Data_Size);
reg [31:0] Mem [0:1023];
output reg[31:0] RD;
input [31:0] WD;
input RE,WE,CLK;
input [11:0] RA,WA;
input [1:0] Data_Size;
ClocK Dj(CLK);
always @(posedge CLK)begin
if (RE==1)begin
  if(Data_Size==0) RD <= Mem[RA/4];
  else if(Data_Size==1) RD <= {16'b0,Mem[RA/4][((RA%4+1)*8-1)+:16]};
  else if(Data_Size==2) RD <= {24'b0,Mem[RA/4][((RA%4+1)*8-1)+:8]};
end
if (WE==1)begin
  if(Data_Size==0) Mem[WA/4] <= WD;
  else if(Data_Size==1) Mem[WA/4][((RA%4+1)*8-1)+:16] <= {16'b0,Mem[RA/4][15:0]};
  else if(Data_Size==2) Mem[WA/4][((RA%4+1)*8-1)+:8] <= {24'b0,Mem[RA/4][7:0]};
end
end
endmodule
module ClocK(clk);
output reg clk;
initial
begin
clk=1'b0;
end
always
begin
#5
clk=~clk;
end
endmodule
module TestBench();
wire [31:0] RD;
reg [31:0] WD;
reg RE,WE;
wire CLK;
reg [11:0] RA,WA;
reg [1:0] Data_Size;
ClocK C(CLK);
Data_Mem DJ(RD,WD,RE,WE,CLK,RA,WA,Data_Size);
initial
begin
@(posedge CLK)
begin
RE=0;
WE=1;
Data_Size = 0;
WA = 4;
WD = 1001;
end
@(posedge CLK)
begin
RE=1;
WE=0;
Data_Size = 0;
RA = 4;
end
$monitor("Write data is %d in Address %d",WD,WA);
$monitor("Read Data is %d in Address %d",RD,RA);
end 
endmodule