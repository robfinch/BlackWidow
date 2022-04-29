	"cmp.eq",				{ RT,RA,RB}						,{BWCOM,  0x0210000000LL},
	"cmp.lt",				{ RT,RA,RB}						,{BWCOM,  0x0200000000LL},
	"cmp.ge",				{ RT,RA,RB}						,{BWCOM,  0x0204000000LL},
	"cmp.le",				{ RT,RA,RB}						,{BWCOM,  0x0208000000LL},
	"cmp.gt",				{ RT,RA,RB}						,{BWCOM,  0x020C000000LL},
	"cmp.ne",				{ RT,RA,RB}						,{BWCOM,  0x0214000000LL},
	"cmpi.eq",			{ RT,RA,SI18}					,{BWCOM,  0x0290000000LL},
	"cmpi.lt",			{ RT,RA,SI18}					,{BWCOM,  0x0280000000LL},
	"cmpi.ge",			{ RT,RA,SI18}					,{BWCOM,  0x0284000000LL},
	"cmpi.le",			{ RT,RA,SI18}					,{BWCOM,  0x0288000000LL},
	"cmpi.gt",			{ RT,RA,SI18}					,{BWCOM,  0x028C000000LL},
	"cmpi.ne",			{ RT,RA,SI18}					,{BWCOM,  0x0294000000LL},
	"cmpu.eq",			{ RT,RA,RB}						,{BWCOM,  0x0250000000LL},
	"cmpu.lt",			{ RT,RA,RB}						,{BWCOM,  0x0240000000LL},
	"cmpu.ge",			{ RT,RA,RB}						,{BWCOM,  0x0244000000LL},
	"cmpu.le",			{ RT,RA,RB}						,{BWCOM,  0x0248000000LL},
	"cmpu.gt",			{ RT,RA,RB}						,{BWCOM,  0x024C000000LL},
	"cmpu.ne",			{ RT,RA,RB}						,{BWCOM,  0x0254000000LL},
	"cmpui.eq",			{ RT,RA,SI18}					,{BWCOM,  0x02B0000000LL},
	"cmpui.lt",			{ RT,RA,SI18}					,{BWCOM,  0x02A0000000LL},
	"cmpui.ge",			{ RT,RA,SI18}					,{BWCOM,  0x02A4000000LL},
	"cmpui.le",			{ RT,RA,SI18}					,{BWCOM,  0x02A8000000LL},
	"cmpui.gt",			{ RT,RA,SI18}					,{BWCOM,  0x02AC000000LL},
	"cmpui.ne",			{ RT,RA,SI18}					,{BWCOM,  0x02B4000000LL},

	"add",					{ RT, RA, RB}					,{BWCOM, 	0x0420000000LL},
	"addi",					{ RT, RA, SI}					,{BWCOM, 	0x0800000000LL},
	"leax",					{ RT, RA, RB}					,{BWCOM, 	0x0420000000LL},
	"lea",					{ RT, RA, SI}					,{BWCOM, 	0x0800000000LL},
	"sub",					{ RT, RA, RB}					,{BWCOM, 	0x0428000000LL},
	"subfi",				{ RT, RA, SI}					,{BWCOM, 	0x0A00000000LL},
	
	"and",					{ RT, RA, RB}					,{BWCOM, 	0x0440000000LL},
	"andi",					{ RT, RA, SI}					,{BWCOM, 	0x1000000000LL},
	"or",						{ RT, RA, RB}					,{BWCOM, 	0x0448000000LL},
	"ori",					{ RT, RA, SI}					,{BWCOM, 	0x1200000000LL},
	"xor",					{ RT, RA, RB}					,{BWCOM, 	0x0450000000LL},
	"xori",					{ RT, RA, SI}					,{BWCOM, 	0x1400000000LL},

	"ldi",					{ RT, SI}							,{BWCOM, 	0x0800000000LL},

	"ldb",					{ RT, D, RA }					,{BWCOM,	0x4000000000LL},
	"ldbu",					{ RT, D, RA }					,{BWCOM,	0x4200000000LL},
	"ldw",					{ RT, D, RA }					,{BWCOM,	0x4400000000LL},
	"ldwu",					{ RT, D, RA }					,{BWCOM,	0x4600000000LL},
	"ldt",					{ RT, D, RA }					,{BWCOM,	0x4800000000LL},
	"ldtu",					{ RT, D, RA }					,{BWCOM,	0x4A00000000LL},
	"ldo",					{ RT, D, RA }					,{BWCOM,	0x4C00000000LL},
	"ldou",					{ RT, D, RA }					,{BWCOM,	0x4E00000000LL},
	"ldh",					{ RT, D, RA }					,{BWCOM,	0x5400000000LL},
	
	"ldbx",					{ RT, RA, RB}					,{BWCOM,	0x0500000000LL},
	"ldbux",				{ RT, RA, RB}					,{BWCOM,	0x0508000000LL},
	"ldwx",					{ RT, RA, RB}					,{BWCOM,	0x0510000000LL},
	"ldwux",				{ RT, RA, RB}					,{BWCOM,	0x0518000000LL},
	"ldtx",					{ RT, RA, RB}					,{BWCOM,	0x0520000000LL},
	"ldtux",				{ RT, RA, RB}					,{BWCOM,	0x0528000000LL},
	"ldox",					{ RT, RA, RB}					,{BWCOM,	0x0530000000LL},
	"ldoux",				{ RT, RA, RB}					,{BWCOM,	0x0538000000LL},
	"ldhx",					{ RT, RA, RB}					,{BWCOM,	0x0548000000LL},

	"stb",					{ RS, D, RA }					,{BWCOM,	0x6000000000LL},
	"stw",					{ RS, D, RA }					,{BWCOM,	0x6200000000LL},
	"stt",					{ RS, D, RA }					,{BWCOM,	0x6400000000LL},
	"sto",					{ RS, D, RA }					,{BWCOM,	0x6600000000LL},
	"sth",					{ RS, D, RA }					,{BWCOM,	0x6800000000LL},

	"stbx",					{ RS, RA, RB}					,{BWCOM,	0x0580000000LL},
	"stwx",					{ RS, RA, RB}					,{BWCOM,	0x0588000000LL},
	"sttx",					{ RS, RA, RB}					,{BWCOM,	0x0590000000LL},
	"stox",					{ RS, RA, RB}					,{BWCOM,	0x0598000000LL},
	"sthx",					{ RS, RA, RB}					,{BWCOM,	0x05A0000000LL},

	"bnz",					{ RAB, BD }						,{BWCOM,	0x1A00000000LL},
	"bz",						{ RAB, BD }						,{BWCOM,	0x1C00000000LL},
	"bra",					{ BD }								,{BWCOM,	0x1C00000000LL},
	"bsr",					{ RT, BD }						,{BWCOM,	0x1E00000000LL},
	"jmr",					{ RT, RA }						,{BWCOM,	0x041A000000LL},
	"nop",					{ 0 }									,{BWCOM, 	0x7800000000LL},

	"sll",					{ RT, RA, RB}					,{BWCOM,	0x0400000000LL},
	"srl",					{ RT, RA, RB}					,{BWCOM,	0x0408000000LL},
	"sra",					{ RT, RA, RB}					,{BWCOM,	0x0410000000LL},
	"slli",					{ RT, RA, UI7}				,{BWCOM,	0x0404000000LL},
	"srli",					{ RT, RA, UI7}				,{BWCOM,	0x040C000000LL},
	"srai",					{ RT, RA, UI7}				,{BWCOM,	0x0414000000LL},
