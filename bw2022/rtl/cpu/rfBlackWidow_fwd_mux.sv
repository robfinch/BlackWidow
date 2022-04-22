import rfBlackWidowPkg::*;

module rfBlackWidow_fwd_mux(Rn, xRt, wRt, xrfwr, wrfwr, xres, wres, rfo, o);
input [5:0] Rn;
input [5:0] xRt;
input [5:0] wRt;
input xrfwr;
input wrfwr;
input Value xres;
input Value wres;
input Value rfo;
output Value o;

always_comb
if (Rn=='d0)
	o = 'd0;
else if (Rn == xRt && xrfwr)
	o = xres;
else if (Rn == wRt && wrfwr)
	o = wres;
else
	o = rfo;

endmodule
