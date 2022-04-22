import rfBlackWidowPkg::*;

module rfBlackWidow_pfwd_mux(pRn, xpRt1, xpRt2, wpRt1, wpRt2, xprfwr, wprfwr, xpres, wpres, prfo, o);
input [5:0] pRn;
input [5:0] xpRt1;
input [5:0] xpRt2;
input [5:0] wpRt1;
input [5:0] wpRt2;
input xprfwr;
input wprfwr;
input xpres;
input wpres;
input prfo;
output o;

always_comb
if (pRn=='d0)
	o = 1'b0;
else if (pRn==6'd1)
	o = 1'b1;
else if (pRn == xpRt1 && xprfwr)
	o = xpres;
else if (pRn == xpRt2 && xprfwr)
	o = ~xpres;
else if (pRn == wpRt1 && wprfwr)
	o = wpres;
else if (pRn == wpRt2 && wprfwr)
	o = ~wpres;
else
	o = rfo;

endmodule
