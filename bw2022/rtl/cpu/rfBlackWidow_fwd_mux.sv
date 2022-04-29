import rfBlackWidowPkg::*;

module rfBlackWidow_fwd_mux(Rn,
	xRt0, xRt1, xRt2, wRt0, wRt1, wRt2, xrfwr0, xrfwr1, xrfwr2,
	wrfwr0, wrfwr1, wrfwr2, xres0, xres1, xres2, wres0, wres1, wres2,
	rfo, o);
input [5:0] Rn;
input [5:0] xRt0;
input [5:0] xRt1;
input [5:0] xRt2;
input [5:0] wRt0;
input [5:0] wRt1;
input [5:0] wRt2;
input xrfwr0;
input xrfwr1;
input xrfwr2;
input wrfwr0;
input wrfwr1;
input wrfwr2;
input Value xres0;
input Value xres1;
input Value xres2;
input Value wres0;
input Value wres1;
input Value wres2;
input Value rfo;
output Value o;

always_comb
if (Rn=='d0)
	o = 'd0;
else if (Rn == xRt2 && xrfwr2)
	o = xres2;
else if (Rn == xRt1 && xrfwr1)
	o = xres1;
else if (Rn == xRt0 && xrfwr0)
	o = xres0;
else if (Rn == wRt2 && wrfwr2)
	o = wres2;
else if (Rn == wRt1 && wrfwr1)
	o = wres1;
else if (Rn == wRt0 && wrfwr0)
	o = wres0;
else
	o = rfo;

endmodule
