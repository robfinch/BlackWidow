import rfBlackWidowPkg::*;

module rfBlackWidow(rst_i, clk_i, clk2x_i, clock, bok_i, bte_o, cti_o, vpa_o, vda_o, 
	cyc_o, stb_o, ack_i, we_o, sel_o, adr_o, dat_i, dat_o, sr_o, cr_o, rb_i);
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
output sr_o;
output cr_o;
input rb_i;

wire clk_g = clk_i;

reg advance_pipe;
reg [79:0] ip, ip0, ip1, ip2;
Address dip, xip;
reg [239:0] insn;
Instruction insn0, insn1, insn2;
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
Value wrfoa0, wrfob0, wrfoc0;
Value xres0, xres1, xres2;
Value wres0, wres1, wres2;
reg [63:0] pregfile;
reg [9:0] asid;
reg [7:0] tid;
MemoryRequest memreq;
MemoryResponse memresp;
wire memq_full;
wire memrq_empty;
wire memrq_v;
reg memrq_rd;

reg dec0en, dec1en, dec2en;
DecoderOut dec0, dec1, dec2;
DecoderOut exc0, exc1, exc2;
DecoderOut wb0, wb1, wb2;

always_comb
	insn = ic_line >> {ip[5:0],3'b0};
always_comb
	insn0 = insn[39:0];
always_comb
	insn1 = insn[79:40];
always_comb
	insn2 = insn[119:80];
	
rfBlackWidow_biu ubiu
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
	.fifoToCtrl_i(memreq),
	.fifoToCtrl_full_o(memq_full),
	.fifoFromCtrl_o(memresp),
	.fifoFromCtrl_rd(memrq_rd),
	.fifoFromCtrl_empty(memrq_empty),
	.fifoFromCtrl_v(memrq_v),
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
	.sr_o(sr_o),
	.cr_o(cr_o),
	.rb_i(rb_i),
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
	wr0 = wb0.rfwr & advance_pipe;
always_comb
	wr1 = wb1.rfwr & advance_pipe;
always_comb
	wr2 = wb2.rfwr & advance_pipe;

rfBlackWidow_gp_regfile urf1
(
	.clk(clk_g),
	.wr0(wr0),
	.wr1(wr1),
	.wr2(wr2),
	.wa0(wb0.Rt),
	.wa1(wb1.Rt),
	.wa2(wb2.Rt),
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
	
rfBlackWidowDecoder udec0
(
	.en(dec0en),
	.ir(ir[39:0]),
	.ir1(ir[79:40]),
	.ir2(ir[119:80]),
	.ir3(ir[159:120]),
	.dec(dec0)
);

rfBlackWidowDecoder udec1
(
	.en(dec1en),
	.ir(ir[79:40]),
	.ir1(ir[119:80]),
	.ir2(ir[159:120]),
	.ir3(ir[199:160]),
	.dec(dec1)
);

rfBlackWidowDecoder udec2
(
	.en(dec2en),
	.ir(ir[119:80]),
	.ir1(ir[159:120]),
	.ir2(ir[199:160]),
	.ir3(ir[239:200]),
	.dec(dec2)
);

rfBlackWidow_fwd_mux ufm0
(
	.Rn(dec0.Ra),
	.xRt0(exc0.Rt),
	.xRt1(exc1.Rt),
	.xRt2(exc2.Rt),
	.wRt0(wb0.Rt),
	.wRt1(wb1.Rt),
	.wRt2(wb2.Rt),
	.xrfwr0(exc0.rfwr),
	.xrfwr1(exc1.rfwr),
	.xrfwr2(exc2.rfwr),
	.wrfwr0(wb0.rfwr),
	.wrfwr1(wb1.rfwr),
	.wrfwr2(wb2.rfwr),
	.xres0(xres0),
	.xres1(xres1),
	.xres2(xres2),
	.wres0(wres0),
	.wres1(wres1),
	.wres2(wres2),
	.rfo(rfo0),
	.o(rfoa0)
);

rfBlackWidow_fwd_mux ufm1
(
	.Rn(dec0.Rb),
	.xRt0(exc0.Rt),
	.xRt1(exc1.Rt),
	.xRt2(exc2.Rt),
	.wRt0(wb0.Rt),
	.wRt1(wb1.Rt),
	.wRt2(wb2.Rt),
	.xrfwr0(exc0.rfwr),
	.xrfwr1(exc1.rfwr),
	.xrfwr2(exc2.rfwr),
	.wrfwr0(wb0.rfwr),
	.wrfwr1(wb1.rfwr),
	.wrfwr2(wb2.rfwr),
	.xres0(xres0),
	.xres1(xres1),
	.xres2(xres2),
	.wres0(wres0),
	.wres1(wres1),
	.wres2(wres2),
	.rfo(rfo1),
	.o(rfob0)
);

rfBlackWidow_fwd_mux ufm2
(
	.Rn(dec0.Rc),
	.xRt0(exc0.Rt),
	.xRt1(exc1.Rt),
	.xRt2(exc2.Rt),
	.wRt0(wb0.Rt),
	.wRt1(wb1.Rt),
	.wRt2(wb2.Rt),
	.xrfwr0(exc0.rfwr),
	.xrfwr1(exc1.rfwr),
	.xrfwr2(exc2.rfwr),
	.wrfwr0(wb0.rfwr),
	.wrfwr1(wb1.rfwr),
	.wrfwr2(wb2.rfwr),
	.xres0(xres0),
	.xres1(xres1),
	.xres2(xres2),
	.wres0(wres0),
	.wres1(wres1),
	.wres2(wres2),
	.rfo(rfo2),
	.o(rfoc0)
);

rfBlackWidow_fwd_mux ufm3
(
	.Rn(dec1.Ra),
	.xRt0(exc0.Rt),
	.xRt1(exc1.Rt),
	.xRt2(exc2.Rt),
	.wRt0(wb0.Rt),
	.wRt1(wb1.Rt),
	.wRt2(wb2.Rt),
	.xrfwr0(exc0.rfwr),
	.xrfwr1(exc1.rfwr),
	.xrfwr2(exc2.rfwr),
	.wrfwr0(wb0.rfwr),
	.wrfwr1(wb1.rfwr),
	.wrfwr2(wb2.rfwr),
	.xres0(xres0),
	.xres1(xres1),
	.xres2(xres2),
	.wres0(wres0),
	.wres1(wres1),
	.wres2(wres2),
	.rfo(rfo3),
	.o(rfoa1)
);

rfBlackWidow_fwd_mux ufm4
(
	.Rn(dec1.Rb),
	.xRt0(exc0.Rt),
	.xRt1(exc1.Rt),
	.xRt2(exc2.Rt),
	.wRt0(wb0.Rt),
	.wRt1(wb1.Rt),
	.wRt2(wb2.Rt),
	.xrfwr0(exc0.rfwr),
	.xrfwr1(exc1.rfwr),
	.xrfwr2(exc2.rfwr),
	.wrfwr0(wb0.rfwr),
	.wrfwr1(wb1.rfwr),
	.wrfwr2(wb2.rfwr),
	.xres0(xres0),
	.xres1(xres1),
	.xres2(xres2),
	.wres0(wres0),
	.wres1(wres1),
	.wres2(wres2),
	.rfo(rfo4),
	.o(rfob1)
);

rfBlackWidow_fwd_mux ufm5
(
	.Rn(dec1.Rc),
	.xRt0(exc0.Rt),
	.xRt1(exc1.Rt),
	.xRt2(exc2.Rt),
	.wRt0(wb0.Rt),
	.wRt1(wb1.Rt),
	.wRt2(wb2.Rt),
	.xrfwr0(exc0.rfwr),
	.xrfwr1(exc1.rfwr),
	.xrfwr2(exc2.rfwr),
	.wrfwr0(wb0.rfwr),
	.wrfwr1(wb1.rfwr),
	.wrfwr2(wb2.rfwr),
	.xres0(xres0),
	.xres1(xres1),
	.xres2(xres2),
	.wres0(wres0),
	.wres1(wres1),
	.wres2(wres2),
	.rfo(rfo5),
	.o(rfoc1)
);

rfBlackWidow_fwd_mux ufm6
(
	.Rn(dec2.Ra),
	.xRt0(exc0.Rt),
	.xRt1(exc1.Rt),
	.xRt2(exc2.Rt),
	.wRt0(wb0.Rt),
	.wRt1(wb1.Rt),
	.wRt2(wb2.Rt),
	.xrfwr0(exc0.rfwr),
	.xrfwr1(exc1.rfwr),
	.xrfwr2(exc2.rfwr),
	.wrfwr0(wb0.rfwr),
	.wrfwr1(wb1.rfwr),
	.wrfwr2(wb2.rfwr),
	.xres0(xres0),
	.xres1(xres1),
	.xres2(xres2),
	.wres0(wres0),
	.wres1(wres1),
	.wres2(wres2),
	.rfo(rfo6),
	.o(rfoa2)
);

rfBlackWidow_fwd_mux ufm7
(
	.Rn(dec2.Rb),
	.xRt0(exc0.Rt),
	.xRt1(exc1.Rt),
	.xRt2(exc2.Rt),
	.wRt0(wb0.Rt),
	.wRt1(wb1.Rt),
	.wRt2(wb2.Rt),
	.xrfwr0(exc0.rfwr),
	.xrfwr1(exc1.rfwr),
	.xrfwr2(exc2.rfwr),
	.wrfwr0(wb0.rfwr),
	.wrfwr1(wb1.rfwr),
	.wrfwr2(wb2.rfwr),
	.xres0(xres0),
	.xres1(xres1),
	.xres2(xres2),
	.wres0(wres0),
	.wres1(wres1),
	.wres2(wres2),
	.rfo(rfo7),
	.o(rfob2)
);

rfBlackWidow_fwd_mux ufm8
(
	.Rn(dec2.Rc),
	.xRt0(exc0.Rt),
	.xRt1(exc1.Rt),
	.xRt2(exc2.Rt),
	.wRt0(wb0.Rt),
	.wRt1(wb1.Rt),
	.wRt2(wb2.Rt),
	.xrfwr0(exc0.rfwr),
	.xrfwr1(exc1.rfwr),
	.xrfwr2(exc2.rfwr),
	.wrfwr0(wb0.rfwr),
	.wrfwr1(wb1.rfwr),
	.wrfwr2(wb2.rfwr),
	.xres0(xres0),
	.xres1(xres1),
	.xres2(xres2),
	.wres0(wres0),
	.wres1(wres1),
	.wres2(wres2),
	.rfo(rfo8),
	.o(rfoc2)
);

rfBlackWidowAlu ualu0 (
	.ir(ir0),
	.ip(ip),
	.a(rfoa0),
	.b(rfob0),
	.c(rfoc0),
	.imm(dec0.imm),
	.tid(tid),
	.res(xres0)
);

rfBlackWidowAlu ualu1 (
	.ir(ir1),
	.ip(ip + 5'd5),
	.a(rfoa1),
	.b(rfob1),
	.c(rfoc1),
	.imm(dec1.imm),
	.tid(8'h00),
	.res(xres1)
);

rfBlackWidowAlu ualu2 (
	.ir(ir2),
	.ip(ip + 5'd10),
	.a(rfoa2),
	.b(rfob2),
	.c(rfoc2),
	.imm(dec2.imm),
	.tid(8'h00),
	.res(xres2)
);

always_comb
	advance_pipe = ihit && !memq_full && (!exc0.ldchk || (memrq_v && memresp.tid >= tid));

task tReset;
begin
	ip <= 80'h00FFFFFFFFFFFFFD0000;
	tid <= 'd0;
	ir0 <= NOP_INSN;
	ir1 <= NOP_INSN;
	ir2 <= NOP_INSN;
	xir0 <= NOP_INSN;
	xir1 <= NOP_INSN;
	xir2 <= NOP_INSN;
	wir0 <= NOP_INSN;
	wir1 <= NOP_INSN;
	wir2 <= NOP_INSN;
	dec0en <= 1'b1;
	dec1en <= 1'b1;
	dec2en <= 1'b1;
	exc0 <= 'd0;
	exc1 <= 'd0;
	exc2 <= 'd0;
	wb0 <= 'd0;
	wb1 <= 'd0;
	wb2 <= 'd0;
end
endtask

task tOnce;
begin
	memreq.wr <= `FALSE;
	memrq_rd <= `FALSE;
end
endtask

task tInsnFetch;
begin
	begin
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
		dip <= ip;
		dec0en <= 1'b1;
		dec1en <= 1'b1;
		dec2en <= 1'b1;
	end
end
endtask

task tDecode;
begin
	begin
		exc0 <= dec0;
		exc1 <= dec1;
		exc2 <= dec2;
		xir0 <= ir0;
		xir1 <= ir1;
		xir2 <= ir2;
		xip <= dip;
	end
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
	dec0en <= 1'd0;
	dec1en <= 1'd0;
	dec2en <= 1'd0;
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

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
/*
task tExMultiCycle;
begin
	begin
	  if (exc0.mulall) begin
	  	aqe_wr <= 1'b1;
//	    goto(MUL1);
	  end
	  else if (exc0.divall) begin
	  	aqe_wr <= 1'b1;
//	    goto(DIV1);
	  end
	  else if (exc0.isDF) begin
	  	aqe_wr <= 1'b1;
//	  	goto (DF1);
	  end
//    if (xFloat)
//      goto(FLOAT1);
	end
end
endtask
*/
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Add memory ops to the memory queue.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

task tExLoad;
begin
  if (exc0.loadr) begin
  	memreq.tid <= tid;
  	tid <= tid + 2'd1;
  	memreq.func <= exc0.loadz ? MR_LOADZ : MR_LOAD;
  	memreq.sz <= exc0.memsz;
  	memreq.adr <= rfoa0 + exc0.imm;
  	memreq.wr <= `TRUE;
  end
  else if (exc0.loadn) begin
  	memreq.tid <= tid;
  	tid <= tid + 2'd1;
  	memreq.func <= exc0.loadz ? MR_LOADZ : MR_LOAD;
  	memreq.sz <= exc0.memsz;
  	memreq.adr <= rfoa0 + rfob0;
  	memreq.wr <= `TRUE;
  end
  else if (exc0.ldchk) begin
  	if (!memrq_v)
  		memrq_rd <= 1'b1;
  	if (memrq_empty)
  		;
  end
end
endtask

task tWbStore;
begin
  if (wb0.storer) begin
  	memreq.tid <= tid;
  	tid <= tid + 2'd1;
  	memreq.func <= MR_STORE;
  	memreq.sz <= wb0.memsz;
  	memreq.adr <= wrfoa0 + wb0.imm;
  	memreq.dat <= wrfoc0;
  	memreq.wr <= `TRUE;
  end
  else if (wb0.storen) begin
  	memreq.tid <= tid;
  	tid <= tid + 2'd1;
  	memreq.func <= MR_STORE;
  	memreq.sz <= wb0.memsz;
  	memreq.adr <= wrfoa0 + wrfob0;
  	memreq.dat <= wrfoc0;
  	memreq.wr <= `TRUE;
  end
end
endtask

task tExecute;
begin
	begin
		wb0 <= exc0;
		wir0 <= xir0;
		wres0 <= xres0;
		wrfoa0 <= rfoa0;
		wrfob0 <= rfob0;
		wrfoc0 <= rfoc0;
		tExLoad();
		wb1 <= exc1;
		wir1 <= xir1;
		wres1 <= xres1;
		wb2 <= exc2;
		wir2 <= xir2;
		wres2 <= xres2;
		if ((exc0.bz && rfoa0=='d0) || (exc0.bnz && rfoa0!='d0)) begin
			ip <= xip + exc0.imm;
			tFlushPipe(2'd0);
		end
		else if ((exc1.bz && rfoa1=='d0) || (exc1.bnz && rfoa1!='d0)) begin
			ip <= xip + exc1.imm + 5'd5;
			tFlushPipe(2'd1);
		end
		else if ((exc2.bz && rfoa2=='d0) || (exc2.bnz && rfoa2!='d0)) begin
			ip <= xip + exc2.imm + 5'd10;
			tFlushPipe(2'd2);
		end
	end
end
endtask

task tWriteback;
begin
	tWbStore();
end
endtask

always_ff @(posedge clk_g)
if (rst_i)
	tReset();
else begin
	tOnce();
	if (advance_pipe) begin
		tInsnFetch();
		tDecode();
		tExecute();
		tWriteback();
	end
end

endmodule
