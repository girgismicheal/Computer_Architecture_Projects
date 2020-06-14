module control_unit(jr,op,RegDst,RegData,RegWr,ALUSrc,ALUOp,MemWr,MemRd,MemtoReg,Jump,Beq,Bne);
	input [5:0] op;
	input jr;
	output  reg[1:0] RegDst , RegData ,Jump ,Data_Size;
	output reg RegWr,ALUSrc,MemtoReg,Beq,Bne ,MemWr , MemRd;
	output reg [3:0] ALUOp;
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
			ALUOp<=0;
			Data_Size<=0;
		end
	always @(jr,op)
		if(op==0)
		begin
			Bne<=0;
			Beq<=0;
			MemtoReg<=0;
			MemRd=0;
			MemWr=0;
			if(jr==1)
			begin
				RegDst<=2'bxx;
				RegData<=2'bxx;
				RegWr<=0;
				ALUSrc<=1'bx;
				ALUOp=11;
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
			Data_Size<=0;
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
				ALUOp<=0;
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
				Data_Size<=0;
			end
			else if(op==33)
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
				Data_Size<=1;
			end
			else if(op==32)
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
				Data_Size<=2;
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
				Data_Size<=0;
                        end
			else if(op==41)
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
				Data_Size<=1;
                        end
			else if(op==40)
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
				Data_Size<=2;
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
                                RegWr<=1;
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
		end
		

endmodule
