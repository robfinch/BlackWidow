import rfBlackWidowPkg::*;

module rfBlackWidow(rst_i, clk_i, clk2x_i, clock, bok_i, bte_o, cti_o, vpa_o, vda_o, 
	cyc_o, stb_o, ack_i, we_o, sel_o, adr_o, dat_i, dat_o);
input rst_i;
input clk_i;
input clk2x_i;
input clock;
input bok_i;
output [1:0] bte_o;
output [2:0] cti_o;
output vpa_o;
output vda_o;
output cyc_o;
output stb_o;
input ack_i;
output we_o;
output [15:0] sel_o;
output Address adr_o;
input [127:0] dat_i;
output [127:0] dat_o;

wire clk_g = clk_i;

reg [79:0] ip, ip0, ip1, ip2;
reg [239:0] insn;
reg [39:0] insn0, insn1, insn2;
wire ihit;
wire [1023:0] ic_line;
reg [239:0] ir;
Instruction ir0, ir1, ir2;
Instruction xir0, xir1, xir2;
Instruction wir0, wir1, wir2;
Value rfo0, rfo1, rfo2;
Value rfo3, rfo4, rfo5;
Value rfo6, rfo7, rfo8;
Value rfoa0, rfob0, rfoc0;
Value rfoa1, rfob1, rfoc1;
Value rfoa2, rfob2, rfoc2;
Value xres0, xres1, xres2;
Value wres0, wres1, wres2;
wire xpres0, xpres1, xpres2;
reg wpres0, wpres1, wpres2;
wire prfo0, prfo1, prfo2;
reg wprfo0, wprfo1, wprfo2;
reg [63:0] pregfile;
reg [9:0] asid;

DecoderOut dec0, dec1, dec2;
DecoderOut exc0, exc1, exc2;
DecoderOut wb0, wb1, wb2;

always_comb
	insn0 = insn[39:0];
always_comb
	insn1 = insn[79:40];
always_comb
	insn2 = insn[119:80];
	
rfBlackWidow_biu ubiu1
(
	.rst(rst_i),
	.clk(clk_g),
	.tlbclk(clk2x_i),
	.clock(clock),
	.UserMode(1'b0),
	.MUserMode(1'b0),
	.omode(2'd3),
	.bounds_chk(),
	.ip(ip),
	.ihit(ihit),
	.ifStall(1'b0),
	.ic_line(ic_line),
	.fifoToCtrl_wack(),
	.fifoToCtrl_i(),
	.fifoToCtrl_full_o(),
	.fifoFromCtrl_o(),
	.fifoFromCtrl_rd(),
	.fifoFromCtrl_empty(),
	.fifoFromCtrl_v(),
	.bok_i(bok_i),
	.bte_o(bte_o),
	.cti_o(cti_o),
	.vpa_o(vpa_o),
	.vda_o(vda_o),
	.cyc_o(cyc_o),
	.stb_o(stb_o),
	.ack_i(ack_i),
	.we_o(we_o),
	.sel_o(sel_o),
	.adr_o(adr_o),
	.dat_i(dat_i),
	.dat_o(dat_o),
	.sr_o(),
	.cr_o(),
	.rb_i(),
	.dce(),
	.arange(),
	.ptbr(ptbr),
	.ipage_fault(),
	.clr_ipage_fault(),
	.itlbmiss(),
	.clr_itlbmiss()
);

reg wr0, wr1, wr2;
always_comb
	wr0 = wb0.rfwr & wprfo0;
always_comb
	wr1 = wb1.rfwr & wprfo1;
always_comb
	wr2 = wb2.rfwr & wprfo2;

rfBlackWidow_gp_regfile urf1
(
	.clk(clk_g),
	.wr0(wr0),
	.wr1(wr1),
	.wr2(wr2),
	.wa0(exc0.Rt),
	.wa1(exc1.Rt),
	.wa2(exc2.Rt),
	.i0(wres0),
	.i1(wres1),
	.i2(wres2),
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
	.o0(rfo0),
	.o1(rfo1),
	.o2(rfo2),
	.o3(rfo3),
	.o4(rfo4),
	.o5(rfo5),
	.o6(rfo6),
	.o7(rfo7),
	.o8(rfo8)
);
	
always_comb
	insn = ic_line >> {ip[3:0],3'b0};

rfBlackWidowDecoder udec0
(
	.ir(ir[39:0]),
	.ir1(ir[79:40]),
	.ir2(ir[119:80]),
	.ir3(ir[159:120]),
	.dec(dec0)
);

rfBlackWidowDecoder udec1
(
	.ir(ir[79:40]),
	.ir1(ir[119:80]),
	.ir2(ir[159:120]),
	.ir3(ir[199:160]),
	.dec(dec1)
);

rfBlackWidowDecoder udec2
(
	.ir(ir[119:80]),
	.ir1(ir[159:120]),
	.ir2(ir[199:160]),
	.ir3(ir[239:200]),
	.dec(dec2)
);

rfBlackWidow_fwd_mux ufm0
(
	.Rn(dec0.Ra),
	.xRt(exc0.Rt),
	.wRt(wb0.Rt),
	.xrfwr(exc0.rfwr),
	.wrfwr(wb0.rfwr),
	.xres(xres0),
	.wres(wres0),
	.rfo(rfo0),
	.o(rfoa0)
);

rfBlackWidow_fwd_mux ufm1
(
	.Rn(dec0.Rb),
	.xRt(exc0.Rt),
	.wRt(wb0.Rt),
	.xrfwr(exc0.rfwr),
	.wrfwr(wb0.rfwr),
	.xres(xres0),
	.wres(wres0),
	.rfo(rfo1),
	.o(rfob0)
);

rfBlackWidow_fwd_mux ufm2
(
	.Rn(dec0.Rc),
	.xRt(exc0.Rt),
	.wRt(wb0.Rt),
	.xrfwr(exc0.rfwr),
	.wrfwr(wb0.rfwr),
	.xres(xres0),
	.wres(wres0),
	.rfo(rfo2),
	.o(rfoc0)
);

rfBlackWidow_fwd_mux ufm3
(
	.Rn(dec1.Ra),
	.xRt(exc1.Rt),
	.wRt(wb1.Rt),
	.xrfwr(exc1.rfwr),
	.wrfwr(wb1.rfwr),
	.xres(xres1),
	.wres(wres1),
	.rfo(rfo3),
	.o(rfoa1)
);

rfBlackWidow_fwd_mux ufm4
(
	.Rn(dec1.Rb),
	.xRt(exc1.Rt),
	.wRt(wb1.Rt),
	.xrfwr(exc1.rfwr),
	.wrfwr(wb1.rfwr),
	.xres(xres1),
	.wres(wres1),
	.rfo(rfo4),
	.o(rfob1)
);

rfBlackWidow_fwd_mux ufm5
(
	.Rn(dec1.Rc),
	.xRt(exc1.Rt),
	.wRt(wb1.Rt),
	.xrfwr(exc1.rfwr),
	.wrfwr(wb1.rfwr),
	.xres(xres1),
	.wres(wres1),
	.rfo(rfo5),
	.o(rfoc1)
);

rfBlackWidow_fwd_mux ufm6
(
	.Rn(dec2.Ra),
	.xRt(exc2.Rt),
	.wRt(wb2.Rt),
	.xrfwr(exc2.rfwr),
	.wrfwr(wb2.rfwr),
	.xres(xres2),
	.wres(wres2),
	.rfo(rfo6),
	.o(rfoa2)
);

rfBlackWidow_fwd_mux ufm7
(
	.Rn(dec2.Rb),
	.xRt(exc2.Rt),
	.wRt(wb2.Rt),
	.xrfwr(exc2.rfwr),
	.wrfwr(wb2.rfwr),
	.xres(xres2),
	.wres(wres2),
	.rfo(rfo7),
	.o(rfob2)
);

rfBlackWidow_fwd_mux ufm8
(
	.Rn(dec2.Rc),
	.xRt(exc2.Rt),
	.wRt(wb2.Rt),
	.xrfwr(exc2.rfwr),
	.wrfwr(wb2.rfwr),
	.xres(xres2),
	.wres(wres2),
	.rfo(rfo8),
	.o(rfoc2)
);

rfBlackWidow_pfwd_mux upfm0
(
	.pRn(ir0.Pn),
	.xpRt1(exc0.pRt1),
	.xpRt2(exc0.pRt2),
	.wpRt1(wb0.pRt1),
	.wpRt2(wb0.pRt2),
	.xprfwr(exc0.prfwr),
	.wprfwr(wb0.prfwr),
	.xpres(xpres0),
	.wpres(wpres0),
	.prfo(pregfile[ir0.Pn]),
	.o(prfo0)
);

rfBlackWidow_pfwd_mux upfm1
(
	.pRn(ir1.Pn),
	.xpRt1(exc1.pRt1),
	.xpRt2(exc1.pRt2),
	.wpRt1(wb1.pRt1),
	.wpRt2(wb1.pRt2),
	.xprfwr(exc1.prfwr),
	.wprfwr(wb1.prfwr),
	.xpres(xpres1),
	.wpres(wpres1),
	.prfo(pregfile[ir1.Pn]),
	.o(prfo1)
);

rfBlackWidow_pfwd_mux upfm2
(
	.pRn(ir2.Pn),
	.xpRt1(exc2.pRt1),
	.xpRt2(exc2.pRt2),
	.wpRt1(wb2.pRt1),
	.wpRt2(wb2.pRt2),
	.xprfwr(exc2.prfwr),
	.wprfwr(wb2.prfwr),
	.xpres(xpres2),
	.wpres(wpres2),
	.prfo(pregfile[ir2.Pn]),
	.o(prfo2)
);

rfBlackWidowAlu ualu0 (
	.ir(ir0),
	.ip(ip),
	.a(rfoa0),
	.b(rfob0),
	.c(rfoc0),
	.imm(dec0.imm),
	.res(xres0)
);

rfBlackWidowAlu ualu1 (
	.ir(ir1),
	.ip(ip + 5'd5),
	.a(rfoa1),
	.b(rfob1),
	.c(rfoc1),
	.imm(dec1.imm),
	.res(xres1)
);

rfBlackWidowAlu ualu2 (
	.ir(ir2),
	.ip(ip + 5'd10),
	.a(rfoa2),
	.b(rfob2),
	.c(rfoc2),
	.imm(dec2.imm),
	.res(xres2)
);

rfBlackWidow_cmp_unit ucmp0
(
	.ir(ir0),
	.a(rfoa0),
	.b(rfob0),
	.imm(dec0.imm),
	.res(xpres0)
);

rfBlackWidow_cmp_unit ucmp1
(
	.ir(ir1),
	.a(rfoa1),
	.b(rfob1),
	.imm(dec1.imm),
	.res(xpres1)
);

rfBlackWidow_cmp_unit ucmp2
(
	.ir(ir2),
	.a(rfoa2),
	.b(rfob2),
	.imm(dec2.imm),
	.res(xpres2)
);

always_comb
	tgt0 = xres0;

task tReset;
begin
	ip <= 80'h00FFFFFFFFFFFFFD0000;
end
endtask

task tInsnFetch;
begin
	if (ihit) begin
		ir <= insn[239:0];
		ir0 <= insn[39:0];
		ir1 <= insn0.any.b ? NOP_INSN : insn[79:40];
		ir2 <= insn0.any.b | insn1.any.b ? NOP_INSN : insn[119:80];
		if (insn0.any.b) begin
			ip <= ip + 4'd5;
		end
		else if (insn1.any.b) begin
			ip <= ip + 4'd10;
		end
		else begin
			ip <= ip + 4'd15;
		end
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

task tFlushPipe;
input [1:0] slot;
begin
	ir0 <= NOP_INSN;
	ir1 <= NOP_INSN;
	ir2 <= NOP_INSN;
	xir0 <= NOP_INSN;
	xir1 <= NOP_INSN;
	xir2 <= NOP_INSN;
	dec0 <= 'd0;
	dec1 <= 'd0;
	dec2 <= 'd0;
	exc0 <= 'd0;
	exc1 <= 'd0;
	exc2 <= 'd0;
	if (slot==2'd0) begin
		wir1 <= NOP_INSN;
		wir2 <= NOP_INSN;
		wb1 <= 'd0;
		wb2 <= 'd0;
	end
	else if (slot==2'd1) begin
		wir2 <= NOP_INSN;
		wb2 <= 'd0;
	end
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
	wres0 <= xres0;
	wres1 <= xres1;
	wres2 <= xres2;
	wpres0 <= xpres0;
	wpres1 <= xpres1;
	wpres2 <= xpres2;
	wprfo0 <= prfo0;
	wprfo1 <= prfo1;
	wprfo2 <= prfo2;
	if (exc0.dec.br & prfo0) begin
		ip <= xip + exc0.imm;
		tFlushPipe(2'd0);
	end
	else if (exc1.dec.br & prfo1) begin
		ip <= xip + exc1.imm + 5'd5;
		tFlushPipe(2'd1);
	end
	else if (exc2.dec.br & prfo2) begin
		ip <= xip + exc2.imm + 5'd10;
		tFlushPipe(2'd2);
	end
end
endtask

task tWriteback;
begin
	if (wb0.prfwr & wprfo0) begin
		pregfile[wb0.pRt1] =  wpres0;
		pregfile[wb0.pRt2] = ~wpres0;
	end
	if (wb1.prfwr & wprfo1) begin
		pregfile[wb1.pRt1] =  wpres1;
		pregfile[wb1.pRt2] = ~wpres1;
	end
	if (wb2.prfwr & wprfo2) begin
		pregfile[wb2.pRt1] =  wpres2;
		pregfile[wb2.pRt2] = ~wpres2;
	end
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
