import rfBlackWidowPkg::*;

module rfBlackWidowDecoder(ir, ir1, ir2, ir3, dec);
input Instruction ir;
input Instruction ir1;
input Instruction ir2;
input Instruction ir3;
output DecoderOut dec;

always_comb
begin
	dec.Ra = ir.r2.Ra;
	dec.Rb = ir.r2.Rb;
	dec.Rc = 'd0;
	dec.Rt = 'd0;
	dec.rfwr = 1'b0;
	dec.prfwr = 1'b0;
	dec.br = 1'b0;
	dec.imm = 'd0;
	dec.pn = ir.any.pr;
	dec.pRt1 = 'd0;
	dec.pRt2 = 'd0;
	dec.memsz = 'd0;
	dec.loadz = 1'b0;
	dec.loadr = 1'b0;
	dec.loadn = 1'b0;
	dec.storer = 1'b0;
	dec.storen = 1'b0;
	dec.ldchk = 1'b0;
	case(ir.any.opcode)
	R2:
		case(ir.r2.func)
		ADD,SUB,AND,OR,XOR:
			begin
				dec.Rt = ir.r2.Rt;
				dec.rfwr = 1'b1;
			end
		CMP,CMPU:
			begin
				dec.prfwr = 1'b1;
				dec.pRt1 = ir.cmp.pt1;
				dec.pRt2 = ir.cmp.pt2;
			end
		LDBX,LDWX,LDTX,LDOX,LDPX,LDDX:
			begin
				dec.Rt = ir.ri.Rt;
				dec.rfwr = 1'b1;
				dec.loadn = 1'b1;
			end
		LDBUX,LDWUX,LDTUX,LDOUX,LDPUX:
			begin
				dec.Rt = ir.ri.Rt;
				dec.rfwr = 1'b1;
				dec.loadz = 1'b1;
				dec.loadn = 1'b1;
			end
		LDCHK:	dec.ldchk = 1'b1;
		STBX,STWX,STTX,STOX,STPX,STDX:
			begin
				dec.Rc = ir.ri.Rt;
				dec.storen = 1'b1;
			end
		JMP:
			begin	
				dec.br = 1'b1;
				dec.Rt = ir.r2.Rt;
				dec.rfwr = 1'b1;
			end
		default:	
			begin
			end
		endcase	
	ADDI,SUBFI,ANDI,ORI,XORI:
		begin
			dec.Rt = ir.ri.Rt;
			dec.rfwr = 1'b1;
			dec.imm = {{65{ir.ri.imm[14]}},ir.ri.imm};
		end
	CMPI,CMPUI:
		begin
			dec.prfwr = 1'b1;
			dec.imm = {{74{ir.cmpi.imm[5]}},ir.cmpi.imm};
			dec.pRt1 = ir.cmpi.pt1;
			dec.pRt2 = ir.cmpi.pt2;
		end
	LDB,LDW,LDT,LDO,LDP,LDD:
		begin
			dec.Rt = ir.ri.Rt;
			dec.rfwr = 1'b1;
			dec.imm = {{65{ir.ri.imm[14]}},ir.ri.imm};
			dec.loadr = 1'b1;
		end
	LDBU,LDWU,LDTU,LDOU,LDPU:
		begin
			dec.Rt = ir.ri.Rt;
			dec.rfwr = 1'b1;
			dec.imm = {{65{ir.ri.imm[14]}},ir.ri.imm};
			dec.loadz = 1'b1;
			dec.loadr = 1'b1;
		end
	STB,STW,STT,STO,STP,STD:	
		begin
			dec.Rc = ir.ri.Rt;
			dec.imm = {{65{ir.ri.imm[14]}},ir.ri.imm};
			dec.storer = 1'b1;
		end
	BRA:
		begin
			dec.imm = {{53{ir.br.disp[26]}},ir.br.disp};
			dec.br = 1'b1;
		end
	BMR:
		begin
			dec.imm = {{53{ir.br.disp[26]}},ir.br.disp};
			dec.br = 1'b1;
			dec.rfwr = 1'b1;
			dec.Rt = 6'd1;
		end
	BMR:
		begin
			dec.imm = {{53{ir.br.disp[26]}},ir.br.disp};
			dec.br = 1'b1;
			dec.rfwr = 1'b1;
			dec.Rt = 6'd2;
		end
	default:
		begin
		end
	endcase
	case(ir1.any.opcode)
	R2:
		case(ir1.r2.func)
		LDBX,LDBUX,STBX:	dec.memsz = byt;
		LDWX,LDWUX,STWX:	dec.memsz = wyde;
		LDTX,LDTUX,STTX:	dec.memsz = tetra;
		LDOX,LDOUX,STOX: dec.memsz = octa;
		LDPX,LDPUX,STPX:	dec.memsz = penta;
		LDDX,STDX:			dec.memsz = deci;
		default:	dec.memsz = deci;
		endcase
	LDB,LDBU,STB:	dec.memsz = byt;
	LDW,LDWU,STW:	dec.memsz = wyde;
	LDT,LDTU,STT:	dec.memsz = tetra;
	LDO,LDOU,STO: dec.memsz = octa;
	LDP,LDPU,STP:	dec.memsz = penta;
	LDD,STD:			dec.memsz = deci;
	default:	dec.memsz = deci;
	endcase
	case(ir1.any.opcode)
	CON1: dec.imm[79:6] = {{47{ir.con.imm[26]}},ir.con.imm};
	CON2:	dec.imm[79:33] = {{20{ir.con.imm[26]}},ir.con.imm};
	CON3: dec.imm[79:60] = ir.con.imm[19:0];
	default:	;
	endcase
	case(ir2.any.opcode)
	CON2: dec.imm[79:33] = {{20{ir.con.imm[26]}},ir.con.imm};
	CON3: dec.imm[79:60] = ir.con.imm[19:0];
	default:	;
	endcase
	case(ir2.any.opcode)
	CON3: dec.imm[79:60] = ir.con.imm[19:0];
	default:	;
	endcase
end

endmodule
