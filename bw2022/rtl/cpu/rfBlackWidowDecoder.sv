import rfBlackWidowPkg::*;

module rfBlackWidowDecoder(en, ir, ir1, ir2, ir3, dec);
input en;
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
	dec.bz = 1'b0;
	dec.bnz = 1'b0;
	dec.imm = 'd0;
	dec.memsz = 'd0;
	dec.loadz = 1'b0;
	dec.loadr = 1'b0;
	dec.loadn = 1'b0;
	dec.storer = 1'b0;
	dec.storen = 1'b0;
	dec.ldchk = 1'b0;
	dec.pn = 'd0;
	if (en) begin
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
					dec.rfwr = 1'b1;
					dec.Rt = ir.cmp.Rt;
				end
			LDBX,LDWX,LDTX,LDOX,LDHX:
				begin
					dec.Rt = ir.ri.Rt;
					dec.rfwr = 1'b1;
					dec.loadn = 1'b1;
				end
			LDBUX,LDWUX,LDTUX,LDOUX:
				begin
					dec.Rt = ir.ri.Rt;
					dec.rfwr = 1'b1;
					dec.loadz = 1'b1;
					dec.loadn = 1'b1;
				end
			LDCHK:	dec.ldchk = 1'b1;
			STBX,STWX,STTX,STOX,STHX:
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
				dec.imm = {{107{ir.ri.imm[20]}},ir.ri.imm};
			end
		CMPI,CMPUI:
			begin
				dec.rfwr = 1'b1;
				dec.imm = {{110{ir.cmpi.imm[17]}},ir.cmpi.imm};
				dec.Rt = ir.cmpi.Rt;
			end
		LDB,LDW,LDT,LDO,LDH:
			begin
				dec.Rt = ir.ri.Rt;
				dec.rfwr = 1'b1;
				dec.imm = {{107{ir.ri.imm[20]}},ir.ri.imm};
				dec.loadr = 1'b1;
			end
		LDBU,LDWU,LDTU,LDOU:
			begin
				dec.Rt = ir.ri.Rt;
				dec.rfwr = 1'b1;
				dec.imm = {{107{ir.ri.imm[20]}},ir.ri.imm};
				dec.loadz = 1'b1;
				dec.loadr = 1'b1;
			end
		STB,STW,STT,STO,STH:	
			begin
				dec.Rc = ir.ri.Rt;
				dec.imm = {{107{ir.ri.imm[20]}},ir.ri.imm};
				dec.storer = 1'b1;
			end
		BZ:
			begin
				dec.imm = {{101{ir.br.disp[26]}},ir.br.disp};
				dec.br = 1'b1;
				dec.Ra = ir.br.Ra;
				dec.bz = 1'b1;
			end
		BNZ:
			begin
				dec.imm = {{101{ir.br.disp[26]}},ir.br.disp};
				dec.br = 1'b1;
				dec.Ra = ir.br.Ra;
				dec.bnz = 1'b1;
			end
		BSR:
			begin
				dec.imm = {{101{ir.br.disp[26]}},ir.br.disp};
				dec.br = 1'b1;
				dec.rfwr = 1'b1;
				dec.Rt = ir.bsr.Rt;
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
			LDHX,STHX:			dec.memsz = hexi;
			default:	dec.memsz = hexi;
			endcase
		LDB,LDBU,STB:	dec.memsz = byt;
		LDW,LDWU,STW:	dec.memsz = wyde;
		LDT,LDTU,STT:	dec.memsz = tetra;
		LDO,LDOU,STO: dec.memsz = octa;
		LDH,STH:			dec.memsz = hexi;
		default:	dec.memsz = hexi;
		endcase
		case(ir1.any.opcode)
		CON1: dec.imm[127:18] = {{77{ir.con.imm[32]}},ir.con.imm};
		CON2:	dec.imm[127:51] = {{44{ir.con.imm[32]}},ir.con.imm};
		CON3: dec.imm[127:84] = {{11{ir.con.imm[32]}},ir.con.imm};
		CON4: dec.imm[127:117] = ir.con.imm[10:0];
		default:	;
		endcase
		case(ir2.any.opcode)
		CON2:	dec.imm[127:51] = {{44{ir.con.imm[32]}},ir.con.imm};
		CON3: dec.imm[127:84] = {{11{ir.con.imm[32]}},ir.con.imm};
		CON4: dec.imm[127:117] = ir.con.imm[10:0];
		default:	;
		endcase
		case(ir3.any.opcode)
		CON3: dec.imm[127:84] = {{11{ir.con.imm[32]}},ir.con.imm};
		CON4: dec.imm[127:117] = ir.con.imm[10:0];
		default:	;
		endcase
		/*
		case(ir4.any.opcode)
		CON4: dec.imm[127:117] = ir.con.imm[10:0];
		default:	;
		endcase
		*/
	end
end

endmodule
