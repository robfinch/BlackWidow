import rfBlackWidowPkg::*;

module rfBlackWidow_cmp_unit(ir, a, b, imm, res);
input Instruction ir;
input Value a;
input Value b;
input Value imm;
output res;

always_comb
case(ir.any.opcode)
R2:
CMP:
	case(ir.cmp.op)
	LT:	res = $signed(a) < $signed(b);
	GE:	res = $signed(a) >= $signed(b);
	LE:	res = $signed(a) <= $signed(b);
	GT:	res = $signed(a) > $signed(b);
	EQ:	res = $signed(a) == $signed(b);
	NE:	res = $signed(a) != $signed(b);
	default:	res = 1'b0;
	endcase
CMPU:
	case(ir.cmp.op)
	LT:	res = a < b;
	GE:	res = a >= b;
	LE:	res = a <= b;
	GT:	res = a > b;
	EQ:	res = a == b;
	NE:	res = a != b;
	default:	res = 1'b0;
	endcase
CMPI:
	case(ir.cmp.op)
	LT:	res = $signed(a) < $signed(imm);
	GE:	res = $signed(a) >= $signed(imm);
	LE:	res = $signed(a) <= $signed(imm);
	GT:	res = $signed(a) > $signed(imm);
	EQ:	res = $signed(a) == $signed(imm);
	NE:	res = $signed(a) != $signed(imm);
	default:	res = 1'b0;
	endcase
CMPUI:
	case(ir.cmp.op)
	LT:	res = a < imm;
	GE:	res = a >= imm;
	LE:	res = a <= imm;
	GT:	res = a > imm;
	EQ:	res = a == imm;
	NE:	res = a != imm;
	default:	res = 1'b0;
	endcase
endcase

endmodule
