`ifndef TRUE
`define TRUE    1'b1
`define FALSE   1'b0
`endif
`ifndef VAL
`define VAL		1'b1
`define INV		1'b0
`endif

package rfBlackWidowPkg;

parameter TRUE = 1'b1;
parameter FALSE = 1'b0;

parameter RSTIP	= 80'hFFFFFFFFFFFFFFFD0000;

parameter R2		= 6'd2;
parameter ADDI	= 6'd4;
parameter SUBFI	= 6'd5;
parameter ANDI	= 6'd8;
parameter ORI		= 6'd9;
parameter XORI	= 6'd10;
parameter MULI	= 6'd12;
parameter BRA		= 6'd13;
parameter BSR		= 6'd14;
parameter BMR		= 6'd15;
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
parameter LDCHK	= 6'd47;
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
parameter JMP		= 6'd13;
parameter SET		= 6'd28;
parameter SETU	= 6'd29;
parameter FSET	= 6'd30;

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

parameter NOP_INSN	= 40'hF000000000;

// Memory Op sizes
parameter byt = 3'd0;
parameter wyde = 3'd1;
parameter tetra = 3'd2;
parameter octa = 3'd3;
parameter penta = 3'd4;
parameter deci = 3'd5;
parameter ptr = 3'd7;

parameter MR_LOAD = 4'd0;
parameter MR_STORE = 4'd1;
parameter MR_TLB = 4'd2;
parameter MR_CACHE = 4'd3;
parameter LEA2 = 4'd4;
//parameter RTS2 = 3'd5;
parameter M_JALI	= 4'd5;
parameter M_CALL	= 4'd6;
parameter MR_LOADZ = 4'd7;		// unsigned load
parameter MR_MFSEL = 4'd8;
parameter MR_MTSEL = 4'd9;
parameter MR_MOVLD = 4'd10;
parameter MR_MOVST = 4'd11;
parameter MR_RGN = 4'd12;
parameter MR_PTG = 4'd15;

parameter CSR_CAUSE	= 16'h?006;
parameter CSR_SEMA	= 16'h?00C;
parameter CSR_PTBR	= 16'h1003;
parameter CSR_ARTBR	= 16'h1005;
parameter CSR_FSTAT	= 16'h?014;
parameter CSR_ASID	= 16'h101F;
parameter CSR_KEYS	= 16'b00010000001000??;
parameter CSR_KEYTBL= 16'h1024;
parameter CSR_SCRATCH=16'h?041;
parameter CSR_MCR0	= 16'h3000;
parameter CSR_MHARTID = 16'h3001;
parameter CSR_TICK	= 16'h3002;
parameter CSR_MBADADDR	= 16'h3007;
parameter CSR_MTVEC = 16'b0011000000110???;
parameter CSR_MPLSTACK	= 16'h303F;
parameter CSR_MPMSTACK	= 16'h3040;
parameter CSR_MSTUFF0	= 16'h3042;
parameter CSR_MSTUFF1	= 16'h3043;
parameter CSR_MSTATUS	= 16'h3044;
parameter CSR_MVSTEP= 16'h3046;
parameter CSR_MVTMP	= 16'h3047;
parameter CSR_MEIP	=	16'h3048;
parameter CSR_MECS	= 16'h3049;
parameter CSR_MPCS	= 16'h304A;
parameter CSR_UCA		=	16'b00000001000?????;
parameter CSR_SCA		=	16'b00010001000?????;
parameter CSR_HCA		=	16'b00100001000?????;
parameter CSR_MCA		=	16'b00110001000?????;
parameter CSR_MSEL	= 16'b0011010000100???;
parameter CSR_MTCBPTR=16'h3050;
parameter CSR_MGDT	= 16'h3051;
parameter CSR_MLDT	= 16'h3052;
parameter CSR_MTCB	= 16'h3054;
parameter CSR_MBVEC	= 16'b0011000001011???;
parameter CSR_MSP		= 16'h3060;
parameter CSR_TIME	= 16'h?FE0;
parameter CSR_MTIME	= 16'h3FE0;
parameter CSR_MTIMECMP	= 16'h3FE1;

parameter FLT_NONE	= 8'h00;
parameter FLT_TLBMISS = 8'h04;
parameter FLT_IADR	= 8'h22;
parameter FLT_CHK		= 8'h27;
parameter FLT_DBZ		= 8'h28;
parameter FLT_OFL		= 8'h29;
parameter FLT_KEY		= 8'h31;
parameter FLT_WRV		= 8'h32;
parameter FLT_RDV		= 8'h33;
parameter FLT_SGB		= 8'h34;
parameter FLT_PRIV	= 8'h35;
parameter FLT_WD		= 8'h36;
parameter FLT_UNIMP	= 8'h37;
parameter FLT_CPF		= 8'h39;
parameter FLT_DPF		= 8'h3A;
parameter FLT_LVL		= 8'h3B;
parameter FLT_PMA		= 8'h3D;
parameter FLT_BRK		= 8'h3F;
parameter FLT_PFX		= 8'hC8;
parameter FLT_TMR		= 8'hE2;
parameter FLT_NMI		= 8'hFE;

parameter pL1CacheLines = 64;
parameter pL1LineSize = 512;
parameter pL1ICacheLines = 512;
parameter pL1ICacheLineSize = 1024;
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
	logic [2:0] op;
	logic [11:0] imm;
	logic [5:0] Ra;
	logic [5:0] Rt;
	logic [5:0] pr;
} setiinst;

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
	setiinst seti;
	brinst br;
	anyinst any;
} Instruction;

typedef struct packed
{
	logic [5:0] pn;
	logic [5:0] Ra;
	logic [5:0] Rb;
	logic [5:0] Rc;
	logic [5:0] Rt;
	logic [5:0] pRt1;
	logic [5:0] pRt2;
	Value imm;
	logic rfwr;
	logic prfwr;
	logic br;
	logic loadz;
	logic loadr;
	logic loadn;
	logic storer;
	logic storen;
	logic ldchk;
	logic [2:0] memsz;
} DecoderOut;

// No unsigned codes!
parameter MR_LDB	= 4'd0;
parameter MR_LDW	= 4'd1;
parameter MR_LDT	= 4'd2;
parameter MR_LDO	= 4'd3;
parameter MR_LDOR	= 4'd4;
parameter MR_LDOB	= 4'd5;
parameter MR_LDOO = 4'd6;
parameter MR_LDH	= 4'd7;
parameter MR_LDHP = 4'd8;
parameter MR_LDPTG = 4'd0;
parameter MR_STPTG = 4'd1;
parameter MR_LDDESC = 4'd12;
parameter MR_STB	= 4'd0;
parameter MR_STW	= 4'd1;
parameter MR_STT	= 4'd2;
parameter MR_STO	= 4'd3;
parameter MR_STOC	= 4'd4;
parameter MR_STOO	= 4'd5;
parameter MR_STH	= 4'd7;
parameter MR_STHP	= 4'd8;
parameter MR_STPTR	= 4'd9;

typedef struct packed
{
	logic [7:0] tid;		// tran id
	logic [5:0] step;		// vector operation step
	logic wr;
	logic [3:0] func;		// function to perform
	logic [3:0] func2;	// more resolution to function
	Address adr;
	logic [255:0] dat;
	logic [3:0] sz;		// indicates size of data
} MemoryRequest;	// 315

// All the fields in this structure are *output* back to the system.
typedef struct packed
{
	logic [7:0] tid;		// tran id
	logic [5:0] step;
	logic wr;
	logic [3:0] func;		// function to perform
	logic [3:0] func2;	// more resolution to function
	logic v;
	logic empty;
	logic [15:0] cause;
	Address badAddr;
	logic [511:0] res;
	logic cmt;
} MemoryResponse;	// 619

endpackage
