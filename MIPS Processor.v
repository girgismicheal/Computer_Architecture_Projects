`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name:    MIPS_Processor
// Module Name:    MIPS_Processor 
// Project Name:   CO_Project#1
//
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module ClockGen(op);
output reg op;
initial op <= 0;
always begin
  #5 op <= !op;
end
endmodule


module PC(ip,op, CLK);
input CLK;
input [31:0] ip;
output reg [31:0] op;
integer h;
initial begin
  op = 32'd0;
  op = op-1;
end
always @(posedge CLK)
 op <= ip;

always @(posedge CLK) 
    begin
      h = $fopen("D:/ReadAddress/PC.txt");
      $fwrite(h,"%h",op);
      $fclose(h) ;
    end

endmodule


module sll16(op,ip);
input [15:0] ip;
output [31:0] op;
assign op = {ip, 16'd0};
endmodule


module adder(A,B,C);
input [31:0] A,B;
output [31:0] C;
assign C = A+B;
endmodule


module MUX3_5bit(sel,in1,in2,in3,out);
	input [4:0] in1,in2,in3;
	input [1:0] sel;
	output reg [4:0] out;
	always @(sel, in1 ,in2,in3)
	begin
		case(sel)
			2'b00:
				out<=in1;
			2'b01:
				out<=in2;
			default:
				out<=in3;
		endcase
	end
endmodule

module MUX3_32bit(sel,in1,in2,in3,out);
	input [31:0] in1,in2,in3;
	input [1:0] sel;
	output reg [31:0] out;
	always @(sel, in1 ,in2,in3)
	begin
		case(sel)
			2'b00:
				out<=in1;
			2'b01:
				out<=in2;
			default:
				out<=in3;
		endcase
	end
endmodule

module MUX2_32bit(sel,in1,in2,out);
	input [31:0] in1,in2;
	input  sel;
	output reg [31:0] out;
	always @(sel, in1 ,in2)
	begin
		case(sel)
			1'b0:
				out<=in1;
			default:
				out<=in2;
		endcase
	end
endmodule



module SignExt(op, ip);
input [15:0] ip;
output [31:0] op;
assign op = {{16{ip[15]}}, ip[15:0]};
endmodule


module Concat(msb, in_add, out_add);
input [5:0] msb;
input [25:0] in_add;
output [31:0] out_add;
assign out_add = {msb, in_add};
endmodule


module BranchLogic(beq, bne, zero, branch);
input beq, bne, zero;
output branch;
wire a,b;
and(a, beq, zero);
and(b, bne, ~zero);
or(branch, a, b);
endmodule


module MIPSALU(C,zero, A,B,Shift,ctrl);
input signed [31:0] A,B;
input [3:0] ctrl;
input [4:0] Shift;
output reg signed 
[31:0] C;
output zero;
assign zero = (C == 0);
always @(*) begin
  case(ctrl)
    0: C <= A&B; 		//AND
    1: C <= A|B; 		//OR
    2: C <= ~(A&B); 		//NAND
    3: C <= ~(A|B) ;		//NOR
    4: C <= A^B;		//XOR
    5: C <= A~^B;		//XNOR
    6: C <= A+B;		//ADD
    7: C <= A-B;		//SUB
//    8: C <= A*B;		//MULT
//    9: C <= A/B;		//DIV
//    10: C <= A%B;		//MOD
    11: C <= 0;			//Zero (NOP)
    12: case (A<B)
	  1: C<=1;
	  default: C<=0;
	endcase		//SLT
    13: C <= B<<Shift;		//SLL
    14: C <= B>>Shift;		//SRL
    15: C <= B>>>Shift;		//SRA
    default: C <= 0;
  endcase
end
endmodule


module ALUControl(ALUCtrl,jr, CtrlOp,FnCode);
input [5:0] FnCode, CtrlOp;
output reg [3:0] ALUCtrl;
output jr;

assign jr = (FnCode == 8);
always@(*) begin
  case(CtrlOp)
  0: case (FnCode)		//ENTER ALL FNs HERE!!
	0:  ALUCtrl <=13;  //SLL
	2:  ALUCtrl <=14;  //SRL
	3:  ALUCtrl <=15;  //SRA
	32: ALUCtrl <=6;  //ADD
	34: ALUCtrl <=7;  //SUB
	36: ALUCtrl <=0;  //AND
	37: ALUCtrl <=1;  //OR
	38: ALUCtrl <=4;  //XOR
	39: ALUCtrl <=3;  //NOR
	42: ALUCtrl <=12;	//SLT
        8:ALUCtrl <=11; 	//Jr 
	default: ALUCtrl <=11; //should not happen
     endcase
  2: ALUCtrl <=0;  //AND
  default: ALUCtrl <= CtrlOp[3:0];
  endcase
end
endmodule


module RegFile(RdData1,RdData2,RdReg1,RdReg2,WrReg,WrData,Write,CLK);
input Write, CLK;
input [4:0] RdReg1,RdReg2,WrReg;
input [31:0] WrData;
output[31:0] RdData1,RdData2;
reg [31:0] RF[0:31];
integer g,i;

assign RdData1 = RF[RdReg1];
assign RdData2 = RF[RdReg2];


initial begin
  RF[5'd0] <= 32'd0;
  RF[5'd29] <= 32'h00001000;
end
always @(posedge CLK) begin
  if(Write)
    RF[WrReg] <= WrData;
end

always @(posedge CLK) 
    begin
      g = $fopen("D:/ReadAddress/Reg_Files.txt");
      for (i = 0; i<32; i=i+4)
        $fwrite(g,"%0d:\t%h\t%h\t%h\t%h\n",i,RF[i],RF[i+1],RF[i+2],RF[i+3]);
      $fclose(g) ;
    end

endmodule


module ControlUnit(jr,op,RegDst,RegData,RegWr,ALUSrc,ALUOp,MemWr,MemRd,MemtoReg,Jump,Beq,Bne);
	input [5:0] op;
	input jr;
	output  reg [1:0] RegDst , RegData ,Jump , MemWr , MemRd;
	output reg RegWr,ALUSrc,MemtoReg,Beq,Bne;
	output reg [5:0] ALUOp;
	initial
		begin
			RegDst <=0;
			RegData<=0;
			MemWr <=0;
			MemRd <=0;
			RegWr <=0;
			ALUSrc <=0;
			MemtoReg <= 0;
			Jump <= 0;
			Beq<=0;
			Bne<=0;
			ALUOp<=11;
		end
	always @(jr,op)
		if(op==0)
		begin
			Bne<=0;
			Beq<=0;
			MemtoReg<=0;
			MemRd<=0;
			MemWr<=0;
			if(jr==1)
			begin
				RegDst<=2'bxx;
				RegData<=2'bxx;
				RegWr<=0;
				ALUSrc<=1'bx;
				ALUOp<=0;
				Jump<=2;				
			end
			else
			begin
				RegDst<=1;
				RegData<=1;
				RegWr<=1;
				ALUSrc<=0;
				ALUOp<=0;
				Jump<=0;
			end
		end
		else
		begin
			Jump<=0;

			if(op==8)
			begin
				RegDst <=0;
				RegData<=1;
				RegWr<=1;
				ALUSrc<=1;
				ALUOp<=6;
				MemWr<=0;
				MemRd<=0;
				MemtoReg<=0;
				Beq<=0;
				Bne<=0;
			end
			else if(op==12)
			begin
				RegDst <=0;
				RegData<=1;
				RegWr<=1;
				ALUSrc<=1;
				ALUOp<=2;
				MemWr<=0;
				MemRd<=0;
				MemtoReg<=0;
				Beq<=0;
				Bne<=0;
			end
			else if(op==13)
			begin
				RegDst <=0;
				RegData<=1;
				RegWr<=1;
				ALUSrc<=1;
				ALUOp<=1;
				MemWr<=0;
				MemRd<=0;
				MemtoReg<=0;
				Beq<=0;
				Bne<=0;
			end
			else if(op==14)
			begin
				RegDst <=0;
				RegData<=1;
				RegWr<=1;
				ALUSrc<=1;
				ALUOp<=4;
				MemWr<=0;
				MemRd<=0;
				MemtoReg<=0;
				Beq<=0;
				Bne<=0;
			end
			else if(op==10)
			begin
				RegDst <=0;
				RegData<=1;
				RegWr<=1;
				ALUSrc<=1;
				ALUOp<=12;
				MemWr<=0;
				MemRd<=0;
				MemtoReg<=0;
				Beq<=0;
				Bne<=0;
			end
			else if(op==15)
			begin
				RegDst <=0;
				RegData<=2;
				RegWr<=1;
				ALUSrc<=1'bx;
				ALUOp<=11;
				MemWr<=0;
				MemRd<=0;
				MemtoReg<=0;
				Beq<=0;
				Bne<=0;
			end
			else if(op==35)
			begin
				RegDst <=0;
				RegData<=1;
				RegWr<=1;
				ALUSrc<=1;
				ALUOp<=6;
				MemWr<=0;
				MemRd<=1;
				MemtoReg<=1;
				Beq<=0;
				Bne<=0;
			end
			else if(op==33)
			begin
				RegDst <=0;
				RegData<=1;
				RegWr<=1;
				ALUSrc<=1;
				ALUOp<=6;
				MemWr<=0;
				MemRd<=2;
				MemtoReg<=1;
				Beq<=0;
				Bne<=0;
			end
			else if(op==32)
                        begin
                                RegDst <=0;
                                RegData<=1;
                                RegWr<=1;
                                ALUSrc<=1;
                                ALUOp<=6;
                                MemWr<=0;
                                MemRd<=3;
                                MemtoReg<=1;
                                Beq<=0;
                                Bne<=0;
                        end
		   else if(op==43)
                        begin
                                RegDst <=2'bxx;
                                RegData<=2'bxx;
                                RegWr<=0;
                                ALUSrc<=1;
                                ALUOp<=6;
                                MemWr<=1;
                                MemRd<=0;
                                MemtoReg<=0;
                                Beq<=0;
                                Bne<=0;
                        end
			else if(op==41)
                        begin
                                RegDst <=2'bxx;
                                RegData<=2'bxx;
                                RegWr<=0;
                                ALUSrc<=1;
                                ALUOp<=6;
                                MemWr<=2;
                                MemRd<=0;
                                MemtoReg<=0;
                                Beq<=0;
                                Bne<=0;
                        end
			else if(op==40)
                        begin
                                RegDst <=2'bxx;
                                RegData<=2'bxx;
                                RegWr<=0;
                                ALUSrc<=1;
                                ALUOp<=6;
                                MemWr<=3;
                                MemRd<=0;
                                MemtoReg<=0;
                                Beq<=0;
                                Bne<=0;
                        end
			else if(op==4)
                        begin
                                RegDst <=2'bxx;
                                RegData<=2'bxx;
                                RegWr<=0;
                                ALUSrc<=0;
                                ALUOp<=7;
                                MemWr<=0;
                                MemRd<=0;
                                MemtoReg<=0;
                                Beq<=1;
                                Bne<=0;
                        end
			else if(op==5)
                        begin
                                RegDst <=2'bxx;
                                RegData<=2'bxx;
                                RegWr<=0;
                                ALUSrc<=0;
                                ALUOp<=7;
                                MemWr<=0;
                                MemRd<=0;
                                MemtoReg<=0;
                                Beq<=0;
                                Bne<=1;
                        end
			else if (op==2)
			begin
				RegDst <=2'bxx;
				RegData<=2'bxx;
				RegWr<=0;
				ALUSrc<=1'bx;
				ALUOp<=11;
				MemWr<=0;
				MemRd<=0;
				MemtoReg<=0;
				Beq<=0;
				Bne<=0;
				Jump<=1;
			end
			else if (op==3)
			begin
				RegDst <=2;
				RegData<=0;
				RegWr<=1;
				ALUSrc<=1'bx;
				ALUOp<=11;
				MemWr<=0;
				MemRd<=0;
				MemtoReg<=0;
				Beq<=0;
				Bne<=0;
				Jump<=1;
			end
			else begin
				Bne<=0;
				Beq<=0;
				MemtoReg<=0;
				MemRd<=0;
				MemWr<=0;
				Jump <= 0;
				RegDst<=1;
				RegData<=1;
				RegWr<=1;
				ALUSrc<=0;
				ALUOp<=0;
				Jump<=0;
		  end
		end
		

endmodule


module DataMem(RD, WD, Address, MemRd, MemWr, CLK);
reg [31:0] DMem [0:1023];
output reg[31:0] RD;
input [31:0] WD;
input [1:0] MemRd, MemWr;
input CLK;
input [31:0] Address;
integer f,i;



always @(*) begin
case(MemRd)
  1:begin		//Load Word
	case(Address%4)
	  0: RD <= DMem[Address/4];
	  1: RD <= {DMem[Address/4+1][ 7:0], DMem[Address/4][31: 8]};
	  2: RD <= {DMem[Address/4+1][15:0], DMem[Address/4][31:16]};
	  3: RD <= {DMem[Address/4+1][23:0], DMem[Address/4][31:24]};
	endcase
    end

  2:begin		//Load Half
	case(Address%4)
	  0: RD <= {16'd0, DMem[Address/4][15: 0]};
	  1: RD <= {16'd0, DMem[Address/4][23: 8]};
	  2: RD <= {16'd0, DMem[Address/4][31:16]};
	  3: RD <= {16'd0, DMem[Address/4+1][7:0], DMem[Address/4][31:24]};
	endcase
    end

  3:begin		//Load Byte
	case(Address%4)
	  3: RD <= {24'd0, DMem[Address/4][31:24]};
	  2: RD <= {24'd0, DMem[Address/4][23:16]};
	  1: RD <= {24'd0, DMem[Address/4][15: 8]};
	  0: RD <= {24'd0, DMem[Address/4][ 7: 0]};
	endcase
    end

endcase

end

always @(posedge CLK)begin

case(MemWr)
      1:begin		//Store Word
  	  case(Address%4)
  	      0: begin DMem[Address/4] <= WD; end
  	      1: begin DMem[Address/4+1][ 7:0] <= WD[31:24]; DMem[Address/4][31: 8] <= WD[23:0]; end
	      2: begin DMem[Address/4+1][15:0] <= WD[31:16]; DMem[Address/4][31:16] <= WD[15:0]; end
	      3: begin DMem[Address/4+1][23:0] <= WD[31: 8]; DMem[Address/4][31:24] <= WD[ 7:0]; end
	  endcase
	end
 
      2:begin		//Store Half
	  case(Address%4)
	    0: DMem[Address/4][15: 0] <= WD[15:0];
	    1: DMem[Address/4][23: 8] <= WD[15:0];
	    2: DMem[Address/4][31:16] <= WD[15:0];
	    3: begin DMem[Address/4+1][7:0] <= WD[15:8]; DMem[Address/4][31:24] <= WD[7:0]; end
	  endcase
	end

      3:begin		//Store Byte
	  case(Address%4)
	    0: DMem[Address/4][7:0] <= WD[7:0];
	    1: DMem[Address/4][15:8] <= WD[7:0];
	    2: DMem[Address/4][23:16] <= WD[7:0];
	    3: DMem[Address/4][31:24] <= WD[7:0];
	  endcase
	end

endcase
end

always @(posedge CLK) 
    begin
      f = $fopen("D:/ReadAddress/DMemory.txt");
      for (i = 0; i<1024; i=i+4)
        $fwrite(f,"%0d:\t%h\t%h\t%h\t%h\n",4*i,DMem[i],DMem[i+1],DMem[i+2],DMem[i+3]);
      $fclose(f) ;
    end

endmodule


module InstMem(Instruction,ReadAddress,clk);
reg[31:0] IMemory[0:1023];
output reg [31:0] Instruction ;
input [31:0] ReadAddress;
input clk;
reg flag =0;
 initial 
begin
$readmemb("D:/ReadAddress/Machine_Code.txt",IMemory);
end
always@(posedge clk)  
begin
  Instruction = IMemory[ReadAddress];
  if(IMemory[ReadAddress] === 32'hxxxxxxxx)
    if(flag) $finish();
    else  flag =1;
end
endmodule 





module MIPSProsssor(instruction);
wire       CLK, Branch, zero, JR, RegWr,ALUSrc,MemtoReg,Beq,Bne;
wire [1:0] RegDst, RegData, MemWr,MemRd, Jump;
wire [3:0] w3;
wire [4:0] WrReg;
wire [5:0] ALUOp;
wire [31:0] PCout, pcin,PCplus4, w1, w2, SignOut, BAddress, BranchMUX, ConCat, WrData, 
            RdData1, RdData2, ALUOut, MemData, WriteData;
output [31:0] instruction;

ClockGen u1(CLK);
PC u21(pcin ,PCout , CLK);
sll16 u12(w1 ,instruction[15:0]);
adder u13(PCout, 32'd1, PCplus4);
adder u14(PCplus4, SignOut, BAddress);
SignExt u2(SignOut , instruction[15:0]);
Concat u3(PCplus4[31:26], instruction[25:0], ConCat);
BranchLogic u4(Beq,Bne, zero, Branch);
MIPSALU u5(ALUOut, zero, RdData1, w2, instruction[10:6], w3);
ALUControl u6(w3, JR, ALUOp, instruction[5:0]);
ControlUnit u8(JR, instruction[31:26],RegDst,RegData,RegWr,ALUSrc,ALUOp,MemWr,MemRd,MemtoReg,Jump,Beq,Bne);
RegFile u7(RdData1, RdData2,instruction[25:21],instruction[20:16], WrReg, WrData, RegWr,CLK);
DataMem u9 (MemData, RdData2, ALUOut, MemRd, MemWr, CLK);
InstMem u10(instruction, pcin, CLK);
MUX3_5bit u15 (RegDst, instruction[20:16],instruction[15:11], 5'd31, WrReg);
MUX3_32bit u16(RegData, PCplus4, WriteData, w1, WrData);
MUX3_32bit u17(Jump, BranchMUX, ConCat, RdData2, pcin);
MUX2_32bit u18(Branch, PCplus4, BAddress, BranchMUX);
MUX2_32bit u19(ALUSrc , RdData2, SignOut, w2);
MUX2_32bit u20(MemtoReg, ALUOut, MemData, WriteData);
endmodule



