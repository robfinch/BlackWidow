// ============================================================================
//        __
//   \\__/ o\    (C) 2022  Robert Finch, Waterloo
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
//
//	rfBlackWidow_gp_regfile.sv
//
//
// BSD 3-Clause License
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// 4600                                                                          
// ============================================================================

import rfBlackWidowPkg::*;

module rfBlackWidow_gp_regfile(clk, wr0, wr1, wr2, wa0, wa1, wa2, i0, i1, i2,
	ip0, ip1, ip2, 
	ra0, ra1, ra2, ra3, ra4, ra5, ra6, ra7, ra8, o0, o1, o2, o3, o4, o5, o6, o7, o8);
input clk;
input wr0;
input wr1;
input wr2;
input [5:0] wa0;
input [5:0] wa1;
input [5:0] wa2;
input Value i0;
input Value i1;
input Value i2;
input CodeAddress ip0;
input CodeAddress ip1;
input CodeAddress ip2;
input [5:0] ra0;
input [5:0] ra1;
input [5:0] ra2;
input [5:0] ra3;
input [5:0] ra4;
input [5:0] ra5;
input [5:0] ra6;
input [5:0] ra7;
input [5:0] ra8;
output Value o0;
output Value o1;
output Value o2;
output Value o3;
output Value o4;
output Value o5;
output Value o6;
output Value o7;
output Value o8;

integer n;
reg [1:0] way [0:31];
Value regfileA [0:31];
Value regfileB [0:31];
Value regfileC [0:31];

initial begin
	for (n = 0; n < 32; n = n + 1) begin
		way[n] = 'd0;
	end	
	for (n = 0; n < 32; n = n + 1) begin
		regfileA[n] = 'd0;
		regfileB[n] = 'd0;
		regfileC[n] = 'd0;
	end
end

always_ff @(posedge clk)
begin
$display("rf writes %c%c%c", wr2?"w":" ", wr1?"w":" ",wr0?"w":" ");
if (wr0) $display("ch0: r%d = %h", wa0, i0);
if (wr1) $display("ch1: r%d = %h", wa1, i1);
if (wr2) $display("ch2: r%d = %h", wa2, i2);
case({wr2,wr1,wr0})
3'b000:	;
// Single writes
3'b001:	begin regfileA[wa0] <= i0; way[wa0] <= 2'd0; end
3'b010:	begin regfileB[wa1] <= i1; way[wa1] <= 2'd1; end
3'b100:	begin regfileC[wa2] <= i2; way[wa2] <= 2'd2; end
// Dual writes
3'b011:
	begin
		if (wa0==wa1) begin
			regfileB[wa1] <= i1;
			way[wa1] <= 2'd1;
		end
		else begin
			regfileA[wa0] <= i0;
			way[wa0] <= 2'd0;
			regfileB[wa1] <= i1;
			way[wa1] <= 2'd1;
		end
	end
3'b101:
	begin
		if (wa0==wa2) begin
			regfileC[wa2] <= i2;
			way[wa2] <= 2'd2;
		end
		else begin
			regfileA[wa0] <= i0;
			way[wa0] <= 2'd0;
			regfileC[wa2] <= i2;
			way[wa2] <= 2'd2;
		end
	end
3'b110:
	begin
		if (wa1==wa2) begin
			regfileC[wa2] <= i2;
			way[wa2] <= 2'd2;
		end
		else begin
			regfileB[wa1] <= i1;
			way[wa1] <= 2'd1;
			regfileC[wa2] <= i2;
			way[wa2] <= 2'd2;
		end
	end
// Triple write
3'b111:
	begin
		if (wa0==wa1 && wa0==wa2) begin
			way[wa0] <= 2'd2;
			regfileC[wa2] <= i2;
		end
		else if (wa0==wa1) begin
			way[wa0] <= 2'd1;
			way[wa2] <= 2'd2;
			regfileB[wa1] <= i1;
			regfileC[wa2] <= i2;
		end
		else if (wa0==wa2) begin
			way[wa0] <= 2'd2;
			way[wa1] <= 2'd1;
			regfileB[wa1] <= i1;
			regfileC[wa2] <= i2;
		end
		else if (wa1==wa2) begin
			way[wa0] <= 2'd0;
			way[wa1] <= 2'd2;
			regfileA[wa0] <= i0;
			regfileC[wa2] <= i2;
		end
	end
endcase
end

always_comb
	o0 = ra0=='d0 ? 'd0 : ra0==wa2 && wr2 ? i2 : ra0==wa1 && wr1 ? i1 : ra0==wa0 && wr0 ? i0 : way[ra0]==2'd2 ? regfileC[ra0] : way[ra0]==2'd1 ? regfileB[ra0] : regfileA[ra0];
always_comb
	o1 = ra1=='d0 ? 'd0 : ra1==wa2 && wr2 ? i2 : ra1==wa1 && wr1 ? i1 : ra1==wa0 && wr0 ? i0 : way[ra1]==2'd2 ? regfileC[ra1] : way[ra1]==2'd1 ? regfileB[ra1] : regfileA[ra1];
always_comb
	o2 = ra2=='d0 ? 'd0 : ra2==wa2 && wr2 ? i2 : ra2==wa1 && wr1 ? i1 : ra2==wa0 && wr0 ? i0 : way[ra2]==2'd2 ? regfileC[ra2] : way[ra2]==2'd1 ? regfileB[ra2] : regfileA[ra2];
always_comb
	o3 = ra3=='d0 ? 'd0 : ra3==wa2 && wr2 ? i2 : ra3==wa1 && wr1 ? i1 : ra3==wa0 && wr0 ? i0 : way[ra3]==2'd2 ? regfileC[ra3] : way[ra3]==2'd1 ? regfileB[ra3] : regfileA[ra3];
always_comb
	o4 = ra4=='d0 ? 'd0 : ra4==wa2 && wr2 ? i2 : ra4==wa1 && wr1 ? i1 : ra4==wa0 && wr0 ? i0 : way[ra4]==2'd2 ? regfileC[ra4] : way[ra4]==2'd1 ? regfileB[ra4] : regfileA[ra4];
always_comb
	o5 = ra5=='d0 ? 'd0 : ra5==wa2 && wr2 ? i2 : ra5==wa1 && wr1 ? i1 : ra5==wa0 && wr0 ? i0 : way[ra5]==2'd2 ? regfileC[ra5] : way[ra5]==2'd1 ? regfileB[ra5] : regfileA[ra5];
always_comb
	o6 = ra6=='d0 ? 'd0 : ra6==wa2 && wr2 ? i2 : ra6==wa1 && wr1 ? i1 : ra6==wa0 && wr0 ? i0 : way[ra6]==2'd2 ? regfileC[ra6] : way[ra6]==2'd1 ? regfileB[ra6] : regfileA[ra6];
always_comb
	o7 = ra7=='d0 ? 'd0 : ra7==wa2 && wr2 ? i2 : ra7==wa1 && wr1 ? i1 : ra7==wa0 && wr0 ? i0 : way[ra7]==2'd2 ? regfileC[ra7] : way[ra7]==2'd1 ? regfileB[ra7] : regfileA[ra7];
always_comb
	o8 = ra8=='d0 ? 'd0 : ra8==wa2 && wr2 ? i2 : ra8==wa1 && wr1 ? i1 : ra8==wa0 && wr0 ? i0 : way[ra8]==2'd2 ? regfileC[ra8] : way[ra8]==2'd1 ? regfileB[ra8] : regfileA[ra8];

endmodule
