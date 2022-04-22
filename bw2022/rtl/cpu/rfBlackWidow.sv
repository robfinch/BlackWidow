import rfBlackWidowPkg::*;

module rfBlackWidow(rst_i, clk_i, );
input rst_i;
input clk_i;

wire clk_g = clk_i;

reg [79:0] ip;
reg [239:0] insn;
wire ihit;
wire [671:0] ic_line;
Instruction ir0, ir1, ir2;
Instruction xir0, xir1, xir2;
Instruction wir0, wir1, wir2;
Value rfoa0, rfob0, rfoc0;
Value rfoa1, rfob1, rfoc1;
Value rfoa2, rfob2, rfoc2;
Value res0, res1, res2;
reg [63:0] pregfile;

DecoderOut dec0, dec1, dec2;
DecoderOut exc0, exc1, exc2;
DecoderOut wb0, wb1, wb2;
reg wr0, wr1, wr2;
always_comb
	wr0 = wb0.rfwr;
always_comb
	if (!wir0.any.b)
		wr1 = wb1.rfwr;
	else
		wr1 = 1'b0;
always_comb
	if (!wir0.any.b && !wir1.any.b)
		wr2 = wb2.rfwr;
	else
		wr2 = 1'b0;

rfBlackWidow_gp_regfile urf1
(
	.clk(clk_g),
	.wr0(wr0),
	.wr1(wr1),
	.wr2(wr2),
	.wa0(exc0.Rt),
	.wa1(exc1.Rt),
	.wa2(exc2.Rt),
	.i0(res0),
	.i1(res1),
	.i2(res2),
	.ip0('d0),
	.ip1('d0),
	.ip2('d0), 
	.ra0(dec0.Ra),
	.ra1(dec0.Rb),
	.ra2(dec0.Rc),
	.ra3(dec1.Ra),
	.ra4(dec1.Rb),
	.ra5(dec1.Rc),
	.ra6(dec2.Ra),
	.ra7(dec2.Rb),
	.ra8(dec2.Rc),
	.o0(rfoa0),
	.o1(rfob0),
	.o2(rfoc0),
	.o3(rfoa1),
	.o4(rfob1),
	.o5(rfoc1),
	.o6(rfoa2),
	.o7(rfob2),
	.o8(rfoc2)
);
	
always_comb
	insn = ic_line >> {ip[3:0],3'b0};

rfBlackWidowDecoder udec0
(
	.ir(insn[39:0]),
	.ir1(insn[79:40]),
	.ir2(insn[119:80]),
	.ir3(insn[159:120]),
	.dec(dec0)
);

rfBlackWidowDecoder udec1
(
	.ir(insn[79:40]),
	.ir1(insn[119:80]),
	.ir2(insn[159:120]),
	.ir3(insn[199:160]),
	.dec(dec1)
);

rfBlackWidowDecoder udec2
(
	.ir(insn[119:80]),
	.ir1(insn[159:120]),
	.ir2(insn[199:160]),
	.ir3(insn[239:200]),
	.dec(dec2)
);

rfBlackWidowAlu ualu0 (
	.ir(ir0),
	.a(rfoa0),
	.b(rfob0),
	.c(rfoc0),
	.imm(dec0.imm),
	.res(res0)
);

rfBlackWidowAlu ualu1 (
	.ir(ir1),
	.a(rfoa1),
	.b(rfob1),
	.c(rfoc1),
	.imm(dec1.imm),
	.res(res1)
);

rfBlackWidowAlu ualu2 (
	.ir(ir2),
	.a(rfoa2),
	.b(rfob2),
	.c(rfoc2),
	.imm(dec2.imm),
	.res(res2)
);

task tReset;
begin
	ip <= 80'h00FFFFFFFFFFFFFD0000;
end
endtask

task tInsnFetch;
begin
	if (ihit) begin
		ir0 <= insn[39:0];
		ir1 <= insn[79:40];
		ir2 <= insn[119:80];
		if (ir0.b)
			ip <= ip + 4'd5;
		else if (ir1.b)
			ip <= ip + 4'd10;
		else
			ip <= ip + 4'd15;
	end
end
endtask

task tDecode;
begin
	exc0 <= dec0;
	exc1 <= dec1;
	exc2 <= dec2;
	xir0 <= ir0;
	xir1 <= ir1;
	xir2 <= ir2;
end
endtask

task tExecute;
begin
	wb0 <= exc0;
	wb1 <= exc1;
	wb2 <= exc2;
	wir0 <= xir0;
	wir1 <= xir1;
	wir2 <= xir2;
end
endtask

task tWriteback;
begin
end
endtask

always_ff @(posedge clk_g)
if (rst_i)
	tReset();
else begin
	tInsnFetch();
	tDecode();
	tExecute();
	tWriteback();
end

endmodule
