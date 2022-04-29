// ============================================================================
//        __
//   \\__/ o\    (C) 2021-2022  Robert Finch, Waterloo
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
//
//	rfBlackWidow_ictag.sv
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
// ============================================================================

import rfBlackWidowPkg::*;
import rfBlackWidowMmuPkg::*;

module rfBlackWidow_ictag(evn, clk, wr, ipo, way, rclk, ip, tag);
parameter LINES=128;
parameter WAYS=4;
parameter AWID=32;
input evn;
input clk;
input wr;
input [AWID-1:0] ipo;
input [1:0] way;
input rclk;
input [AWID-1:0] ip;
(* ram_style="block" *)
output [AWID-1:7] tag [0:3];

reg [AWID-1:7] tags [0:WAYS*LINES-1];
reg [AWID-1:0] rip;

integer g;
integer n;

initial begin
for (g = 0; g < WAYS; g = g + 1) begin
  for (n = 0; n < LINES; n = n + 1)
    tags[g * LINES + n] = 32'd1;
end
end

always_ff @(posedge clk)
begin
	if (wr)
		tags[{way,ipo[13:7]}] <= ipo[AWID-1:7];
end

always_ff @(posedge rclk)
begin
	rip[6:0] <= ip[6:0];	// not used
	rip[13:7] <= ip[13:7] + (evn ? ip[6] : 1'b0);
	rip[AWID-1:14] <= ip[AWID-1:14];
end
assign tag[0] = tags[{2'b00,rip[13:7]}];
assign tag[1] = tags[{2'b01,rip[13:7]}];
assign tag[2] = tags[{2'b10,rip[13:7]}];
assign tag[3] = tags[{2'b11,rip[13:7]}];

endmodule
