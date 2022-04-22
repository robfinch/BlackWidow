import rfBlackWidowPkg::*;

module rfBlackWidowAlu(ir, ip, a, b, c, imm, res);
input Instruction ir;
input Address ip;
input Value a;
input Value b;
input Value c;
input Value imm;
output Value res;

always_comb
case(ir.any.opcode)
R2:
	case(ir.r2.func)
	ADD:	res = a + b;
	SUB:	res = a - b;
	AND:	res = a & b;
	OR:		res = a | b;
	XOR:	res = a ^ b;
	SLL:
		if (ir[26])
			res = a << imm[6:0];
		else
			res = a << b[6:0];
	SRL:
		if (ir[26])
			res = a >> imm[6:0];
		else
			res = a >> b[6:0];
	SRA:
		if (ir[26]) begin
			if (a[79])	res = {{80{1'b1}},a} >> imm[6:0];
			else res = a >> imm[6:0];
		end
		else begin
			if (a[79])	res = {{80{1'b1}},a} >> b[6:0];
			else res = a >> b[6:0];
		end
	SET:
		case(ir[26:24])
		LT:		res = $signed(a) < $signed(b);
		GE:		res = $signed(a) >= $signed(b);
		LE:		res = $signed(a) <= $signed(b);
		GT:		res = $signed(a) > $signed(b);
		EQ:		res = $signed(a) == $signed(b);
		NE:		res = $signed(a) != $signed(b);
		default:	res = 'd0;
		endcase
	SETU:
		case(ir[26:24])
		LT:		res = a < b;
		GE:		res = a >= b;
		LE:		res = a <= b;
		GT:		res = a > b;
		EQ:		res = a == b;
		NE:		res = a != b;
		default:	res = 'd0;
		endcase	
	JMP:			res = ip + 4'd5;
	default:	res = 'd0;
	endcase
ADDI:		res = a + imm;
SUBFI:	res = imm - a;
ANDI:		res = a & imm;
ORI:		res = a | imm;
XORI:		res = a ^ imm;
SETI:
	case(ir.seti.op)
	LT:		res = $signed(a) < $signed(imm);
	GE:		res = $signed(a) >= $signed(imm);
	LE:		res = $signed(a) <= $signed(imm);
	GT:		res = $signed(a) > $signed(imm);
	EQ:		res = a == b;
	NE:		res = a != b;
	default:	res = 'd0;
	endcase
SETUI:
	case(ir.seti.op)
	LT:		res = a < imm;
	GE:		res = a >= imm;
	LE:		res = a <= imm;
	GT:		res = a > imm;
	EQ:		res = a == imm;
	NE:		res = a != imm;
	default:	res = 'd0;
	endcase
BRA:		res = ip + 4'd5;
BSR:		res = ip + 4'd5;
BMR:		res = ip + 4'd5;
default:	res = 'd0;
endcase

endmodule
