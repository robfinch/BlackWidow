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
			end
		LDBX,LDBUX,LDWX,LDWUX,LDTX,LDTUX,LDOX,LDOUX,LDPX,LDPUX,LDDX:
			begin
				dec.Rt = ir.ri.Rt;
				dec.rfwr = 1'b1;
			end
		STBX,STWX,STTX,STOX,STPX,STDX:
			begin
				dec.Rc = ir.ri.Rt;
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
		end
	LDB,LDBU,LDW,LDWU,LDT,LDTU,LDO,LDOU,LDP,LDPU,LDD:
		begin
			dec.Rt = ir.ri.Rt;
			dec.rfwr = 1'b1;
			dec.imm = {{65{ir.ri.imm[14]}},ir.ri.imm};
		end
	STB,STW,STT,STO,STP,STD:	
		begin
			dec.Rc = ir.ri.Rt;
			dec.imm = {{65{ir.ri.imm[14]}},ir.ri.imm};
		end
	default:
		begin
		end
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
