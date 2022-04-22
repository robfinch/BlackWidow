`ifndef TRUE
`define TRUE    1'b1
`define FALSE   1'b0
`endif
`ifndef VAL
`define VAL		1'b1
`define INV		1'b0
`endif

package rfBlackWidowPkg;

parameter R2		= 6'd2;
parameter ADDI	= 6'd4;
parameter SUBFI	= 6'd5;
parameter ANDI	= 6'd8;
parameter ORI		= 6'd9;
parameter XORI	= 6'd10;
parameter MULI	= 6'd12;
parameter CMP		= 6'd16;
parameter CMPU	= 6'd17;
parameter FCMP	= 6'd18;
parameter CMPI	= 6'd20;
parameter CMPUI	= 6'd21;
parameter FCMPI	= 6'd22;
parameter SETI	= 6'd28;
parameter SETUI	= 6'd29;
parameter FSETI	= 6'd30;
parameter LDB		= 6'd32;
parameter LDBU	= 6'd33;
parameter LDW		= 6'd34;
parameter LDWU	= 6'd35;
parameter LDT		= 6'd36;
parameter LDTU	= 6'd37;
parameter LDO		= 6'd38;
parameter LDOU	= 6'd39;
parameter LDP		= 6'd40;
parameter LDPU	= 6'd41;
parameter LDD		= 6'd42;
parameter STB		= 6'd48;
parameter STW		= 6'd49;
parameter STT		= 6'd50;
parameter STO		= 6'd51;
parameter STP		= 6'd52;
parameter STD		= 6'd53;

parameter CON1	= 6'd61;
parameter CON2	= 6'd62;
parameter CON3	= 6'd63;

// R2 ops
parameter SLL		= 6'd0;
parameter SRL		= 6'd1;
parameter SRA		= 6'd2;
parameter ADD		= 6'd4;
parameter SUB 	= 6'd5;
parameter AND		= 6'd8;
parameter OR		= 6'd9;
parameter XOR		= 6'd10;
parameter MUL		= 6'd12;

parameter LDBX	= 6'd32;
parameter LDBUX	= 6'd33;
parameter LDWX	= 6'd34;
parameter LDWUX	= 6'd35;
parameter LDTX	= 6'd36;
parameter LDTUX	= 6'd37;
parameter LDOX	= 6'd38;
parameter LDOUX	= 6'd39;
parameter LDPX	= 6'd40;
parameter LDPUX	= 6'd41;
parameter LDDX	= 6'd42;
parameter STBX	= 6'd48;
parameter STWX	= 6'd49;
parameter STTX	= 6'd50;
parameter STOX	= 6'd51;
parameter STPX	= 6'd52;
parameter STDX	= 6'd53;

// CMP ops
parameter LT		= 3'd0;
parameter GE		= 3'd1;
parameter LE		= 3'd2;
parameter GT		= 3'd3;
parameter EQ		= 3'd4;
parameter NE	 	= 3'd5;

parameter pL1CacheLines = 64;
parameter pL1LineSize = 512;
parameter pL1ICacheLines = 512;
parameter pL1ICacheLineSize = 672;
localparam pL1Imsb = $clog2(pL1ICacheLines-1)-1+6;

typedef logic [39:0] Address;
typedef logic [39:0] CodeAddress;
typedef logic [79:0] Value;

typedef struct packed
{
	logic b;
	logic [5:0] opcode;
	logic [26:0] imm;
	logic [5:0] pr;
} coninst;

typedef struct packed
{
	logic b;
	logic [5:0] opcode;
	logic [5:0] func;
	logic [2:0] pad3;
	logic [5:0] Rb;
	logic [5:0] Ra;
	logic [5:0] Rt;
	logic [5:0] pr;
} r2inst;

typedef struct packed
{
	logic b;
	logic [5:0] opcode;
	logic [14:0] imm;
	logic [5:0] Ra;
	logic [5:0] Rt;
	logic [5:0] pr;
} riinst;

typedef struct packed
{
	logic b;
	logic [5:0] opcode;
	logic [2:0] op;
	logic [5:0] pt2;
	logic [5:0] pt1;
	logic [5:0] Rb;
	logic [5:0] Ra;
	logic [5:0] pr;
} cmpinst;

typedef struct packed
{
	logic b;
	logic [5:0] opcode;
	logic [2:0] op;
	logic [5:0] pt2;
	logic [5:0] pt1;
	logic [5:0] imm;
	logic [5:0] Ra;
	logic [5:0] pr;
} cmpiinst;

typedef struct packed
{
	logic b;
	logic [5:0] opcode;
	logic [26:0] disp;
	logic [5:0] pr;
} brinst;

typedef struct packed
{
	logic b;
	logic [5:0] opcode;
	logic [26:0] payload;
	logic [5:0] pr;
} anyinst;

typedef union packed
{
	coninst con;
	r2inst r2;
	riinst ri;
	cmpinst cmp;
	cmpiinst cmpi;
	brinst br;
	anyinst any;
} Instruction;

typedef struct packed
{
	logic [5:0] Ra;
	logic [5:0] Rb;
	logic [5:0] Rc;
	logic [5:0] Rt;
	Value imm;
	logic rfwr;
	logic prfwr;
} DecoderOut;

endpackage
