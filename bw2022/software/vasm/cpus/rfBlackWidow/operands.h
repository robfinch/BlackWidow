/* Operand description structure */
struct powerpc_operand
{
  int bits;
  int shift;
  uint64_t (*insert)(uint64_t,int64_t,const char **);
  uint32_t flags;
};

/* rfBlackWidow_operand flags */
#define OPER_SIGNED   (1)        /* signed values */
#define OPER_SIGNOPT  (2)        /* signed values up to 0xffff */
#define OPER_FAKE     (4)        /* just reuse last read operand */
#define OPER_PARENS   (8)        /* operand is in parentheses */
#define OPER_CR       (0x10)     /* CR field */
#define OPER_GPR      (0x20)     /* GPR field */
#define OPER_FPR      (0x40)     /* FPR field */
#define OPER_RELATIVE (0x80)     /* relative branch displacement */
#define OPER_ABSOLUTE (0x100)    /* absolute branch address */
#define OPER_OPTIONAL (0x200)    /* optional, zero if omitted */
#define OPER_NEXT     (0x400)    /* hack for rotate instructions */
#define OPER_NEGATIVE (0x800)    /* range check on negative value */
#define OPER_VR       (0x1000)   /* Altivec register field */
#define OPER_PN				(0x2000)		/* predicate register */
#define OPER_SI6			(0x4000)		/* six bit signed immediate */
#define OPER_SI18	  	(0x8000)		/* 27 bit signed branch displacement */

/* Operand types. */
enum {
 	UNUSED,
 	PT1, PT2, SI6, UI7, RAB, SI18,
 	
  BA,BAT,BB,BBA,BD,BDA,BDM,BDMA,BDP,BDPA,BF,OBF,BFA,BI,BO,BOE,
  BT,CR,D,DS,E,FL1,FL2,FLM,FRA,FRB,FRC,FRS,FXM,L,LEV,LI,LIA,MB,ME,
  MBE,MBE_,MB6,NB,NSI,RA,RAL,RAM,RAS,RB,RBS,RS,SH,SH6,SI,SISIGNOPT,
  SPR,SPRBAT,SPRG,SR,SV,TBR,TO,U,UI,VA,VB,VC,VD,SIMM,UIMM,SHB,
  SLWI,SRWI,EXTLWI,EXTRWI,EXTWIB,INSLWI,INSRWI,ROTRWI,CLRRWI,CLRLSL,
  STRM,AT,LS,RSOPT,RAOPT,RBOPT,CT,SHO,CRFS,EVUIMM_2,EVUIMM_4,EVUIMM_8
};

#define FRT FRS
#define ME6 MB6
#define RT RS
#define RTOPT RSOPT
#define VS VD
#define CRB MB
#define PMR SPR
#define TMR SPR
#define CRFD BF
#define EVUIMM SH

#define NEXT (-1)  /* use operand_type+1 for next operand */


/* The functions used to insert complex operands. */

static uint32_t insert_bat(uint64_t insn,int64_t value,const char **errmsg)
{
  return insn | (((insn >> 21) & 0x1f) << 16);
}

static uint32_t insert_bba(uint64_t insn,int64_t value,const char **errmsg)
{
  return insn | (((insn >> 16) & 0x1f) << 11);
}

static uint64_t insert_bd(uint64_t insn,int64_t value,const char **errmsg)
{
  return insn | ((value & 0x7ffffffLL) << 6LL);
}

static uint64_t insert_bdm(uint64_t insn,int64_t value,const char **errmsg)
{
  if ((value & 0x8000) != 0)
    insn |= 1 << 21;
  return insn | (value & 0xfffc);
}

static uint64_t insert_bdp(uint64_t insn,int64_t value,const char **errmsg)
{
  if ((value & 0x8000) == 0)
    insn |= 1 << 21;
  return insn | (value & 0xfffc);
}

static int valid_bo(int64_t value)
{
  switch (value & 0x14) {
    default:
    case 0:
      return 1;
    case 0x4:
      return (value & 0x2) == 0;
    case 0x10:
      return (value & 0x8) == 0;
    case 0x14:
      return value == 0x14;
  }
}

static uint64_t insert_bo(uint64_t insn,int64_t value,const char **errmsg)
{
  if (!valid_bo (value))
    *errmsg = "invalid conditional option";
  return insn | ((value & 0x1f) << 21);
}

static uint64_t insert_boe(uint64_t insn,int64_t value,const char **errmsg)
{
  if (!valid_bo (value))
    *errmsg = "invalid conditional option";
  else if ((value & 1) != 0)
    *errmsg = "attempt to set y bit when using + or - modifier";
  return insn | ((value & 0x1f) << 21);
}

static uint64_t insert_ds(uint64_t insn,int64_t value,const char **errmsg)
{
  return insn | (value & 0xfffc);
}

static uint64_t insert_li(uint64_t insn,int64_t value,const char **errmsg)
{
  if ((value & 3) != 0)
    *errmsg = "ignoring least significant bits in branch offset";
  return insn | (value & 0x3fffffc);
}

static uint64_t insert_mbe(uint64_t insn,int64_t value,const char **errmsg)
{
  uint64_t uval, mask;
  int mb, me, mx, count, last;

  uval = value;

  if (uval == 0) {
      *errmsg = "illegal bitmask";
      return insn;
  }

  mb = 0;
  me = 32;
  if ((uval & 1) != 0)
    last = 1;
  else
    last = 0;
  count = 0;

  for (mx = 0, mask = (int64_t) 1 << 31; mx < 32; ++mx, mask >>= 1) {
    if ((uval & mask) && !last) {
      ++count;
      mb = mx;
      last = 1;
    }
    else if (!(uval & mask) && last) {
      ++count;
      me = mx;
      last = 0;
    }
  }
  if (me == 0)
    me = 32;

  if (count != 2 && (count != 0 || ! last)) {
    *errmsg = "illegal bitmask";
  }

  return insn | (mb << 6) | ((me - 1) << 1);
}

static uint64_t insert_mb6(uint64_t insn,int64_t value,const char **errmsg)
{
  return insn | ((value & 0x1f) << 6) | (value & 0x20);
}

static uint64_t insert_nb(uint64_t insn,int64_t value,const char **errmsg)
{
  if (value < 0 || value > 32)
    *errmsg = "value out of range";
  if (value == 32)
    value = 0;
  return insn | ((value & 0x1f) << 11);
}

static uint64_t insert_nsi(uint64_t insn,int64_t value,const char **errmsg)
{
  return insn | ((- value) & 0xffff);
}

static uint64_t insert_ral(uint64_t insn,int64_t value,const char **errmsg)
{
  if (value == 0
      || (uint64_t) value == ((insn >> 21) & 0x1f))
    *errmsg = "invalid register operand when updating";
  return insn | ((value & 0x1f) << 12);
}

static uint64_t insert_ram(uint64_t insn,int64_t value,const char **errmsg)
{
  if ((uint64_t) value >= ((insn >> 21) & 0x1f))
    *errmsg = "index register in load range";
  return insn | ((value & 0x1f) << 12);
}

static uint64_t insert_ras(uint64_t insn,int64_t value,const char **errmsg)
{
  if (value == 0)
    *errmsg = "invalid register operand when updating";
  return insn | ((value & 0x1f) << 12);
}

static uint64_t insert_rbs(uint64_t insn,int64_t value,const char **errmsg)
{
  return insn | (((insn >> 21) & 0x1f) << 11);
}

static uint64_t insert_sh6(uint64_t insn,int64_t value,const char **errmsg)
{
  return insn | ((value & 0x1f) << 11) | ((value & 0x20) >> 4);
}

static uint64_t insert_spr(uint64_t insn,int64_t value,const char **errmsg)
{
  return insn | ((value & 0x1f) << 16) | ((value & 0x3e0) << 6);
}

static uint64_t insert_sprg(uint64_t insn,int64_t value,const char **errmsg)
{
  /* @@@ only BOOKE, VLE and 405 have 8 SPRGs */
  if (value & ~7)
    *errmsg = "illegal SPRG number";
  if ((insn & 0x100)!=0 || value<=3)
    value |= 0x10;  /* mfsprg 4..7 use SPR260..263 */
  return insn | ((value & 17) << 16);
}

static uint64_t insert_tbr(uint64_t insn,int64_t value,const char **errmsg)
{
  if (value == 0)
    value = 268;
  return insn | ((value & 0x1f) << 16) | ((value & 0x3e0) << 6);
}

static uint64_t insert_slwi(uint64_t insn,int64_t value,const char **errmsg)
{
  return insn | ((value&0x1f)<<11) | ((31-(value&0x1f))<<1);
}

static uint64_t insert_srwi(uint64_t insn,int64_t value,const char **errmsg)
{
  return insn | (((32-value)&0x1f)<<11) | ((value&0x1f)<<6) | (31<<1);
}

static uint64_t insert_extlwi(uint64_t insn,int64_t value,const char **errmsg)
{
  if (value<1 || value>32)
    *errmsg = "value out of range (1-32)";
  return insn | (((value-1)&0x1f)<<1);
}

static uint64_t insert_extrwi(uint64_t insn,int64_t value,const char **errmsg)
{
  if (value<1 || value>32)
    *errmsg = "value out of range (1-32)";
  return insn | ((value&0x1f)<<11) | (((32-value)&0x1f)<<6) | (31<<1);
}

static uint64_t insert_extwib(uint64_t insn,int64_t value,const char **errmsg)
{
  value += (insn>>11) & 0x1f;
  if (value > 32)
    *errmsg = "sum of last two operands out of range (0-32)";
  return (insn&~0xf800) | ((value&0x1f)<<11);
}

static uint64_t insert_inslwi(uint64_t insn,int64_t value,const char **errmsg)
{
  int64_t n = ((insn>>1) & 0x1f) + 1;
  if (value+n > 32)
    *errmsg = "sum of last two operands out of range (1-32)";
  return (insn&~0xfffe) | (((32-value)&0x1f)<<11) | ((value&0x1f)<<6)
                        | ((((value+n)-1)&0x1f)<<1);
}

static uint64_t insert_insrwi(uint64_t insn,int64_t value,const char **errmsg)
{
  int64_t n = ((insn>>1) & 0x1f) + 1;
  if (value+n > 32)
    *errmsg = "sum of last two operands out of range (1-32)";
  return (insn&~0xfffe) | (((32-(value+n))&0x1f)<<11) | ((value&0x1f)<<6)
                        | ((((value+n)-1)&0x1f)<<1);
}

static uint64_t insert_rotrwi(uint64_t insn,int64_t value,const char **errmsg)
{
  return insn | (((32-value)&0x1f)<<11);
}

static uint64_t insert_clrrwi(uint64_t insn,int64_t value,const char **errmsg)
{
  return insn | (((31-value)&0x1f)<<1);
}

static uint64_t insert_clrlslwi(uint64_t insn,int64_t value,const char **errmsg)
{
  int64_t b = (insn>>6) & 0x1f;
  if (value > b)
    *errmsg = "n (4th oper) must be less or equal to b (3rd oper)";
  return (insn&~0x7c0) | ((value&0x1f)<<11) | (((b-value)&0x1f)<<6)
                       | (((31-value)&0x1f)<<1);
}

static uint64_t insert_ls(uint64_t insn,int64_t value,const char **errmsg)
{
  /* @@@ check for POWER4 */
  return insn | ((value&3)<<21);
}


/* The operands table.
   The fields are: bits, shift, insert, flags. */

const struct powerpc_operand powerpc_operands[] =
{
  /* UNUSED */
  { 0, 0, 0, 0 },
  
  /* PT1 */
  { 6, 18, 0, OPER_PN },

  /* PT2 */
  { 6, 24, 0, OPER_PN },

  /* SI6 */
  { 6, 12, 0, OPER_SI6 },

  /* UI7 */
  { 7, 18, 0, OPER_SI6 },

  /* RAB */
  { 6, 0, 0, OPER_GPR },

  /* SI18 */
  { 18, 12, 0, OPER_SI18 },

  /* BA */
  { 5, 16, 0, OPER_CR },

  /* BAT */
  { 5, 16, insert_bat, OPER_FAKE },

  /* BB */
  { 5, 11, 0, OPER_CR },

  /* BBA */
  { 5, 11, insert_bba, OPER_FAKE },

  /* BD */
  { 27, 6, insert_bd, OPER_RELATIVE | OPER_SIGNED },

  /* BDA */
  { 16, 0, insert_bd, OPER_ABSOLUTE | OPER_SIGNED },

  /* BDM */
  { 16, 0, insert_bdm, OPER_RELATIVE | OPER_SIGNED },

  /* BDMA */
  { 16, 0, insert_bdm, OPER_ABSOLUTE | OPER_SIGNED },

  /* BDP */
  { 16, 0, insert_bdp, OPER_RELATIVE | OPER_SIGNED },

  /* BDPA */
  { 16, 0, insert_bdp, OPER_ABSOLUTE | OPER_SIGNED },

  /* BF */
  { 3, 23, 0, OPER_CR },

  /* OBF */
  { 3, 23, 0, OPER_CR | OPER_OPTIONAL },

  /* BFA */
  { 3, 18, 0, OPER_CR },

  /* BI */
  { 5, 16, 0, OPER_CR },

  /* BO */
  { 5, 21, insert_bo, 0 },

  /* BOE */
  { 5, 21, insert_boe, 0 },

  /* BT */
  { 5, 21, 0, OPER_CR },

  /* CR */
  { 3, 18, 0, OPER_CR | OPER_OPTIONAL },

  /* D */
  { 16, 0, 0, OPER_PARENS | OPER_SIGNED },

  /* DS */
  { 16, 0, insert_ds, OPER_PARENS | OPER_SIGNED },

  /* E */
  { 1, 15, 0, 0 },

  /* FL1 */
  { 4, 12, 0, 0 },

  /* FL2 */
  { 3, 2, 0, 0 },

  /* FLM */
  { 8, 17, 0, 0 },

  /* FRA */
  { 5, 16, 0, OPER_FPR },

  /* FRB */
  { 5, 11, 0, OPER_FPR },

  /* FRC */
  { 5, 6, 0, OPER_FPR },

  /* FRS */
  { 5, 21, 0, OPER_FPR },

  /* FXM */
  { 8, 12, 0, 0 },

  /* L */
  { 1, 21, 0, OPER_OPTIONAL },

  /* LEV */
  { 7, 5, 0, 0 },

  /* LI */
  { 26, 0, insert_li, OPER_RELATIVE | OPER_SIGNED },

  /* LIA */
  { 26, 0, insert_li, OPER_ABSOLUTE | OPER_SIGNED },

  /* MB */
  { 5, 6, 0, 0 },

  /* ME */
  { 5, 1, 0, 0 },

  /* MBE */
  { 5, 6, 0, OPER_OPTIONAL | OPER_NEXT },
  /* MBE_ (NEXT) */
  { 31, 1, insert_mbe, 0 },

  /* MB6 */
  { 6, 5, insert_mb6, 0 },

  /* NB */
  { 6, 11, insert_nb, 0 },

  /* NSI */
  { 16, 0, insert_nsi, OPER_NEGATIVE | OPER_SIGNED },

  /* RA */
  { 6, 6, 0, OPER_GPR },

  /* RAL */
  { 5, 16, insert_ral, OPER_GPR },

  /* RAM */
  { 5, 16, insert_ram, OPER_GPR },

  /* RAS */
  { 5, 16, insert_ras, OPER_GPR },

  /* RB */
  { 6, 12, 0, OPER_GPR },

  /* RBS */
  { 5, 1, insert_rbs, OPER_FAKE },

  /* RS */
  { 6, 0, 0, OPER_GPR },

  /* SH */
  { 5, 11, 0, 0 },

  /* SH6 */
  { 6, 1, insert_sh6, 0 },

  /* SI */
  { 15, 18, 0, OPER_SIGNED },

  /* SISIGNOPT */
  { 16, 0, 0, OPER_SIGNED | OPER_SIGNOPT },

  /* SPR */
  { 10, 11, insert_spr, 0 },

  /* SPRBAT */
  { 2, 17, 0, 0 },

  /* SPRG */
  { 3, 16, insert_sprg, 0 },

  /* SR */
  { 4, 16, 0, 0 },

  /* SV */
  { 14, 2, 0, 0 },

  /* TBR */
  { 10, 11, insert_tbr, OPER_OPTIONAL },

  /* TO */
  { 5, 21, 0, 0 },

  /* U */
  { 4, 12, 0, 0 },

  /* UI */
  { 16, 0, 0, 0 },

  /* VA */
  { 5, 16, 0, OPER_VR },

  /* VB */
  { 5, 11, 0, OPER_VR }, 

  /* VC */
  { 5, 6, 0, OPER_VR },

  /* VD */
  { 5, 21, 0, OPER_VR },

  /* SIMM */
  { 5, 16, 0, OPER_SIGNED},

  /* UIMM */
  { 5, 16, 0, 0 },

  /* SHB */
  { 4, 6, 0, 0 },

  /* SLWI */
  { 5, 11, insert_slwi, 0 },

  /* SRWI */
  { 5, 11, insert_srwi, 0 },

  /* EXTLWI */
  { 31, 1, insert_extlwi, 0 },

  /* EXTRWI */
  { 31, 1, insert_extrwi, 0 },

  /* EXTWIB */
  { 5, 11, insert_extwib, 0 },

  /* INSLWI */
  { 5, 11, insert_inslwi, 0 },

  /* INSRWI */
  { 5, 11, insert_insrwi, 0 },

  /* ROTRWI */
  { 5, 11, insert_rotrwi, 0 },

  /* CLRRWI */
  { 5, 1, insert_clrrwi, 0 },

  /* CLRLSL */
  { 5, 11, insert_clrlslwi, 0 },

  /* STRM */
  { 2, 21, 0, 0 },

  /* AT */
  { 1, 25, 0, OPER_OPTIONAL },

  /* LS */
  { 2, 21, insert_ls, OPER_OPTIONAL },

  /* RSOPT */
  { 5, 21, 0, OPER_GPR | OPER_OPTIONAL },

  /* RAOPT */
  { 5, 16, 0, OPER_GPR | OPER_OPTIONAL },

  /* RBOPT */
  { 5, 11, 0, OPER_GPR | OPER_OPTIONAL },

  /* CT */
  { 5, 21, 0, OPER_OPTIONAL },

  /* SHO */
  { 5, 11, 0, OPER_OPTIONAL },
  
  /* CRFS */
  { 3, 0, 0, OPER_CR },

  /* EVUIMM_2 */
  { 5, 10, 0, OPER_PARENS },

  /* EVUIMM_4 */
  { 5, 9, 0, OPER_PARENS },

  /* EVUIMM_8 */
  { 5, 8, 0, OPER_PARENS },
};
