/*
** cpu.c PowerPC cpu-description file
** (c) in 2002-2019 by Frank Wille
*/

#include "vasm.h"
#include "operands.h"

mnemonic mnemonics[] = {
#include "opcodes.h"
};

int mnemonic_cnt=sizeof(mnemonics)/sizeof(mnemonics[0]);

char *cpu_copyright="vasm PowerPC cpu backend 3.1 (c) 2002-2019 Frank Wille\n"
	"vasm rfBlackWidow cpu backend 1.0 (c) 2022 Robert Finch";
char *cpuname = "rfBlackWidow";
int bitsperbyte = 8;
int bytespertaddr = 8;
int ppc_endianess = 0;
int abits=32;

static uint64_t cpu_type = BWCOM;
static int regnames = 1;
static taddr sdreg = 61;  /* */
static taddr sd2reg = 60;
static unsigned char opt_branch = 0;
static unsigned char con1 = 0;
static unsigned char con2 = 0;
static unsigned char con3 = 0;
static unsigned char con4 = 0;
static unsigned char con5 = 0;
static unsigned char got_break = 0;


int ppc_data_align(int n)
{
  if (n<=8) return 1;
  if (n<=16) return 2;
  if (n<=32) return 4;
  return 8;
}

int ppc_data_operand(int n)
{
  if (n&OPSZ_FLOAT) return OPSZ_BITS(n)>32?OP_F64:OP_F32;
  if (OPSZ_BITS(n)<=8) return OP_D8;
  if (OPSZ_BITS(n)<=16) return OP_D16;
  if (OPSZ_BITS(n)<=32) return OP_D32;
  return OP_D64;
}


int ppc_operand_optional(operand *op,int type)
{
  if (powerpc_operands[type].flags & OPER_OPTIONAL) {
    op->attr = REL_NONE;
    op->mode = OPM_NONE;
    op->basereg = NULL;
    op->value = number_expr(0);  /* default value 0 */

    if (powerpc_operands[type].flags & OPER_NEXT)
      op->type = NEXT;
    else
      op->type = type;
    return 1;
  }
  else if (powerpc_operands[type].flags & OPER_FAKE) {
    op->type = type;
    op->value = NULL;
    return 1;
  }

  return 0;
}


int ppc_available(int idx)
/* Check if mnemonic is available for selected cpu_type. */
{
  uint64_t avail = mnemonics[idx].ext.available;
  uint64_t datawidth = CPU_TYPE_32 | CPU_TYPE_64;

  if ((avail & cpu_type) != 0) {
    if ((avail & cpu_type & ~datawidth)!=0 || (cpu_type & CPU_TYPE_ANY)!=0) {
      if (avail & datawidth)
        return (avail & datawidth) == (cpu_type & datawidth)
               || (cpu_type & CPU_TYPE_64_BRIDGE) != 0;
      else
        return 1;
    }
  }
  return 0;
}

/* check if a given value fits within a certain number of bits */
static int is_nbit(int64_t val, int64_t n)
{
	int64_t low, high;
  if (n > 63)
    return (1);
	low = -(1LL << (n - 1LL));
	high = (1LL << (n - 1LL));
	return (val >= low && val < high);
}

static char *parse_reloc_attr(char *p,operand *op)
{
  p = skip(p);
  while (*p == '@') {
    unsigned char chk;

    p++;
    chk = op->attr;
    if (!strncmp(p,"got",3)) {
      op->attr = REL_GOT;
      p += 3;
    }
    else if (!strncmp(p,"plt",3)) {
      op->attr = REL_PLT;
      p += 3;
    }
    else if (!strncmp(p,"sdax",4)) {
      op->attr = REL_SD;
      p += 4;
    }
    else if (!strncmp(p,"sdarx",5)) {
      op->attr = REL_SD;
      p += 5;
    }
    else if (!strncmp(p,"sdarel",6)) {
      op->attr = REL_SD;
      p += 6;
    }
    else if (!strncmp(p,"sectoff",7)) {
      op->attr = REL_SECOFF;
      p += 7;
    }
    else if (!strncmp(p,"local",5)) {
      op->attr = REL_LOCALPC;
      p += 5;
    }
    else if (!strncmp(p,"globdat",7)) {
      op->attr = REL_GLOBDAT;
      p += 7;
    }
    else if (!strncmp(p,"sda2rel",7)) {
      op->attr = REL_PPCEABI_SDA2;
      p += 7;
    }
    else if (!strncmp(p,"sda21",5)) {
      op->attr = REL_PPCEABI_SDA21;
      p += 5;
    }
    else if (!strncmp(p,"sdai16",6)) {
      op->attr = REL_PPCEABI_SDAI16;
      p += 6;
    }
    else if (!strncmp(p,"sda2i16",7)) {
      op->attr = REL_PPCEABI_SDA2I16;
      p += 7;
    }
    else if (!strncmp(p,"drel",4)) {
      op->attr = REL_MORPHOS_DREL;
      p += 4;
    }
    else if (!strncmp(p,"brel",4)) {
      op->attr = REL_AMIGAOS_BREL;
      p += 4;
    }
    if (chk!=REL_NONE && chk!=op->attr)
      cpu_error(7);  /* multiple relocation attributes */

    chk = op->mode;
    if (!strncmp(p,"ha",2)) {
      op->mode = OPM_HA;
      p += 2;
    }
    if (*p == 'h') {
      op->mode = OPM_HI;
      p++;
    }
    if (*p == 'l') {
      op->mode = OPM_LO;
      p++;
    }
    if (chk!=OPM_NONE && chk!=op->mode)
      cpu_error(8);  /* multiple hi/lo modifiers */
  }

  return p;
}


int parse_operand(char *p,int len,operand *op,int optype)
/* Parses operands, reads expressions and assigns relocation types. */
{
  char *start = p;
  int rc = PO_MATCH;
  char needpa = 0;

  op->attr = REL_NONE;
  op->mode = OPM_NONE;
  op->basereg = NULL;

  p = skip(p);
  /* Look for indexed addressing */
  if (*p=='[') {
  	p++;
  	p = skip(p);
  	needpa = 1;
	  op->basereg = parse_expr(&p);
  	p = skip(p);
  	if (*p==',') {
  		p++;
  		p = skip(p);
  		op->ndxreg = parse_expr(&p);
  		rc = PO_SKIP;
  	}
  	p = skip(p);
  	if (*p!=']') {
      cpu_error(5);  /* missing closing parenthesis */
      rc = PO_CORRUPT;
      goto leave;
  	}
  	goto chksemi;
  }

  op->value = OP_FLOAT(optype) ? parse_expr_float(&p) : parse_expr(&p);

  if (!OP_DATA(optype)) {
    p = parse_reloc_attr(p,op);
    p = skip(p);

    if (p-start < len && *p=='[') {
      /* parse d[Rn] load/store addressing mode */
      if (powerpc_operands[optype].flags & OPER_PARENS) {
        p++;
        op->basereg = parse_expr(&p);
        p = skip(p);
        if (*p == ']') {
          p = skip(p+1);
          rc = PO_SKIP;
        }
        else {
          cpu_error(5);  /* missing closing parenthesis */
          rc = PO_CORRUPT;
          goto leave;
        }
      }
      else {
        cpu_error(4);  /* illegal operand type */
        rc = PO_CORRUPT;
//        rc = PO_NOMATCH;
        goto leave;
      }
    }
  }
chksemi:
  if (p-start < len) {
  	p = skip(p);
  	if (*p==';') {
  		op->mode |= OPM_BREAK;
  		p++;
  	}
  	if (p-start < len)
    	cpu_error(3);  /* trailing garbage in operand */
  }
leave:
  op->type = optype;
  return rc;
}


static taddr read_sdreg(char **s,taddr def)
{
  expr *tree;
  taddr val = def;

  *s = skip(*s);
  tree = parse_expr(s);
  simplify_expr(tree);
  if (tree->type==NUM && tree->c.val>=0 && tree->c.val<=63)
    val = tree->c.val;
  else
    cpu_error(13);  /* not a valid register */
  free_expr(tree);
  return val;
}


char *parse_cpu_special(char *start)
/* parse cpu-specific directives; return pointer to end of
   cpu-specific text */
{
  char *name=start,*s=start;

  if (ISIDSTART(*s)) {
    s++;
    while (ISIDCHAR(*s))
      s++;
    if (s-name==6 && !strncmp(name,".sdreg",6)) {
      sdreg = read_sdreg(&s,sdreg);
      return s;
    }
    else if (s-name==7 && !strncmp(name,".sd2reg",7)) {
      sd2reg = read_sdreg(&s,sd2reg);
      return s;
    }
  }
  return start;
}


static int get_reloc_type(operand *op)
{
  int rtype = REL_NONE;

  if (OP_DATA(op->type)) {  /* data relocs */
    return REL_ABS;
  }

  else {  /* handle instruction relocs */
    const struct powerpc_operand *ppcop = &powerpc_operands[op->type];

    if (ppcop->shift == 6) {
      if (ppcop->bits == 27) {

        if (ppcop->flags & OPER_RELATIVE) {  /* a relative branch */
          switch (op->attr) {
            case REL_NONE:
              rtype = REL_PC;
              break;
            case REL_PLT:
              rtype = REL_PLTPC;
              break;
            case REL_LOCALPC:
              rtype = REL_LOCALPC;
              break;
            default:
              cpu_error(11); /* reloc attribute not supported by operand */
              break;
          }
        }

        else if (ppcop->flags & OPER_ABSOLUTE) { /* absolute branch */
          switch (op->attr) {
            case REL_NONE:
              rtype = REL_ABS;
              break;
            case REL_PLT:
            case REL_GLOBDAT:
            case REL_SECOFF:
              rtype = op->attr;
              break;
            default:
              cpu_error(11); /* reloc attribute not supported by operand */
              break;
          }
        }

        else {  /* immediate 16 bit or load/store d16(Rn) instruction */
          switch (op->attr) {
            case REL_NONE:
              rtype = REL_ABS;
              break;
            case REL_GOT:
            case REL_PLT:
            case REL_SD:
            case REL_PPCEABI_SDA2:
            case REL_PPCEABI_SDA21:
            case REL_PPCEABI_SDAI16:
            case REL_PPCEABI_SDA2I16:
            case REL_MORPHOS_DREL:
            case REL_AMIGAOS_BREL:
              rtype = op->attr;
              break;
            default:
              cpu_error(11); /* reloc attribute not supported by operand */
              break;
          }
        }
      }
    }
  }

  return rtype;
}


static int valid_hiloreloc(int type)
/* checks if this relocation type allows a @l/@h/@ha modifier */
{
  switch (type) {
    case REL_ABS:
    case REL_GOT:
    case REL_PLT:
    case REL_MORPHOS_DREL:
    case REL_AMIGAOS_BREL:
      return 1;
  }
  cpu_error(6);  /* relocation does not allow hi/lo modifier */
  return 0;
}


static taddr make_reloc(int reloctype,operand *op,section *sec,
                        taddr pc,rlist **reloclist)
/* create a reloc-entry when operand contains a non-constant expression */
{
  taddr val;

  if (!eval_expr(op->value,&val,sec,pc)) {
    /* non-constant expression requires a relocation entry */
    symbol *base;
    int btype,pos,size,offset;
    taddr addend,mask;

    btype = find_base(op->value,&base,sec,pc);
    pos = offset = 0;

    if (btype > BASE_ILLEGAL) {
      if (btype == BASE_PCREL) {
        if (reloctype == REL_ABS)
          reloctype = REL_PC;
        else
          goto illreloc;
      }

      if (op->mode != OPM_NONE) {
        /* check if reloc allows @ha/@h/@l */
        if (!valid_hiloreloc(reloctype))
          op->mode = OPM_NONE;
      }

      if (reloctype == REL_PC && !is_pc_reloc(base,sec)) {
        /* a relative branch - reloc is only needed for external reference */
        return val-pc;
      }

      /* determine reloc size, offset and mask */
      if (OP_DATA(op->type)) {  /* data operand */
        switch (op->type) {
          case OP_D8:
            size = 8;
            break;
          case OP_D16:
            size = 16;
            break;
          case OP_D32:
          case OP_F32:
            size = 32;
            break;
          case OP_D64:
          case OP_F64:
            size = 64;
            break;
          default:
            ierror(0);
            break;
        }
        addend = val;
        mask = -1;
      }
      else {  /* instruction operand */
        const struct powerpc_operand *ppcop = &powerpc_operands[op->type];

        if (ppcop->flags & (OPER_RELATIVE|OPER_ABSOLUTE)) {
          /* branch instruction */
          size = 27;
          pos = 6;
          mask = 0x7ffffff;
          addend = (btype == BASE_PCREL) ? val + offset : val;
        }
        else {
          /* load/store or immediate */
          size = 15;
          offset = 2;
          addend = (btype == BASE_PCREL) ? val + offset : val;
          switch (op->mode) {
            case OPM_LO:
              mask = 0xffff;
              break;
            case OPM_HI:
              mask = 0xffff0000;
              break;
            case OPM_HA:
              add_extnreloc_masked(reloclist,base,addend,reloctype,
                                   pos,size,offset,0x8000);
              mask = 0xffff0000;
              break;
            default:
              mask = -1;
              break;
          }
        }
      }

      add_extnreloc_masked(reloclist,base,addend,reloctype,
                           pos,size,offset,mask);
      if (!is_nbit(addend,15)) {
	      add_extnreloc_masked(reloclist,base,addend,reloctype,
	                           46,27,0,0x1ffffffc0LL);
	      if (!is_nbit(addend,33)) {
		      add_extnreloc_masked(reloclist,base,addend,reloctype,
		                           86,27,0,0xffffffe00000000LL);
		      if (!is_nbit(addend,60)) {
			      add_extnreloc_masked(reloclist,base,addend,reloctype,
		                           126,27,0,0xf000000000000000LL);
		      	
		      }
	      	
	      }
      }
    }
    else if (btype != BASE_NONE) {
illreloc:
      general_error(38);  /* illegal relocation */
    }
  }
  else {
     if (reloctype == REL_PC) {
       /* a relative reference to an absolute label */
       return val-pc;
     }
  }

  return val;
}


static void fix_reloctype(dblock *db,int rtype)
{
  rlist *rl;

  for (rl=db->relocs; rl!=NULL; rl=rl->next)
    rl->type = rtype;
}


static void range_check(taddr val,const struct powerpc_operand *o,dblock *db)
/* checks if a value fits the allowed range for this operand field */
{
  int32_t v = (int32_t)val;
  int32_t minv = 0;
  int32_t maxv = (1L << o->bits) - 1;
  int force_signopt = 0;

  if (db) {
    if (db->relocs) {
      switch (db->relocs->type) {
        case REL_SD:
        case REL_PPCEABI_SDA2:
        case REL_PPCEABI_SDA21:
          force_signopt = 1;  /* relocation allows full positive range */
          break;
      }
    }
  }

  if (o->flags & OPER_SIGNED) {
  	return;
    minv = ~(maxv >> 1);

    /* @@@ Only recognize this flag in 32-bit mode! Don't care for now */
    if (!(o->flags & OPER_SIGNOPT) && !force_signopt)
      maxv >>= 1;
  }
  if (o->flags & OPER_NEGATIVE)
    v = -v;

  if (v<minv || v>maxv)
    cpu_error(12,v,minv,maxv);  /* operand out of range */
}


static void negate_bo_cond(uint32_t *p)
/* negates all conditions in a branch instruction's BO field */
{
  if (!(*p & 0x02000000))
    *p ^= 0x01000000;
  if (!(*p & 0x00800000))
    *p ^= 0x00400000;
}


static uint64_t insertcode(uint64_t i,taddr val,
                           const struct powerpc_operand *o)
{
  if (o->insert) {
    const char *errmsg = NULL;

    i = (o->insert)(i,(int64_t)val,&errmsg);
    if (errmsg)
      cpu_error(0,errmsg);
  }
  else
    i |= ((int64_t)val & ((1LL<<o->bits)-1LL)) << o->shift;

  return i;
}


size_t eval_operands(instruction *ip,section *sec,taddr pc,
                     uint64_t *insn,dblock *db)
/* evaluate expressions and try to optimize instruction,
   return size of instruction */
{
  mnemonic *mnemo = &mnemonics[ip->code];
  size_t isize = 5;
  int i;
  operand op;
	con1 = con2 = con3 = 0;

  if (insn != NULL)
    *insn = mnemo->ext.opcode;

  for (i=0; i<MAX_OPERANDS && ip->op[i]!=NULL; i++) {
    const struct powerpc_operand *ppcop;
    int reloctype;
    taddr val;

    op = *(ip->op[i]);

    if (op.type == NEXT) {
      /* special case: operand omitted and use this operand's type + 1
         for the next operand */
      op = *(ip->op[++i]);
      op.type = mnemo->operand_type[i-1] + 1;
    }

    ppcop = &powerpc_operands[op.type];

    if (ppcop->flags & OPER_FAKE) {
      if (insn != NULL) {
        if (op.value != NULL)
          cpu_error(16);  /* ignoring fake operand */
        *insn = insertcode(*insn,0,ppcop);
      }
      continue;
    }

    if ((reloctype = get_reloc_type(&op)) != REL_NONE) {
      if (db != NULL) {
        val = make_reloc(reloctype,&op,sec,pc,&db->relocs);
      }
      else {
        if (!eval_expr(op.value,&val,sec,pc)) {
          if (reloctype == REL_PC)
            val -= pc;
        }
      }
    }
    else {
      if (!eval_expr(op.value,&val,sec,pc))
        if (insn != NULL) {
        	printf("1: err found\n");
          cpu_error(2);  /* constant integer expression required */
        }
    }

    /* execute modifier on val */
    if (op.mode) {
      switch (op.mode & 0x7f) {
        case OPM_LO:
          val &= 0xffff;
          break;
        case OPM_HI:
          val = (val>>16) & 0xffff;
          break;
        case OPM_HA:
          val = ((val>>16) + ((val & 0x8000) ? 1 : 0) & 0xffff);
          break;
      }
//      if ((ppcop->flags & OPER_SIGNED) && (val & 0x8000))
//        val -= 0x10000;
    }
    if (op.mode & OPM_BREAK) {
    	got_break = 1;
    }
    
    if ((ppcop->flags & OPER_SIGNED)) {
			if (!is_nbit(val,21)) {
				con1 = 1;
				isize += 5;
				if (!is_nbit(val,45)) {
					con2 = 1;
					isize += 5;
					/*
					if (!is_nbit(val,72)) {
						con3 = 1;
						isize += 5;
					}
					*/
				}
			}
			if (insn != NULL) {
				if (con1) {
					insn++;
					*insn = 0x7A00000000LL | (((val >> 18LL) & 0x7ffffffLL) << 6LL);
				}
				if (con2) {
					insn++;
					*insn = 0x7C00000000LL | (((val >> 45LL) & 0x7ffffffLL) << 6LL);
				}
				/*
				if (con3) {
					insn++;
					*insn = 0x7E00000000LL | (((val >> 72LL) & 0xfLL) << 6LL);
				}
				*/
			}
		}
    if ((ppcop->flags & OPER_SI18)) {
			if (!is_nbit(val,18)) {
				con1 = 1;
				isize += 5;
				if (!is_nbit(val,45)) {
					con2 = 1;
					isize += 5;
					/*
					if (!is_nbit(val,72)) {
						con3 = 1;
						isize += 5;
					}
					*/
				}
			}
			if (insn != NULL) {
				if (con1) {
					insn++;
					*insn = 0x7A00000000LL | (((val >> 18LL) & 0x7ffffffLL) << 6LL);
				}
				if (con2) {
					insn++;
					*insn = 0x7C00000000LL | (((val >> 45LL) & 0x7ffffffLL) << 6LL);
				}
				/*
				if (con3) {
					insn++;
					*insn = 0x7E00000000LL | (((val >> 72LL) & 0xfLL) << 6LL);
				}
				*/
			}
		}

    /* do optimizations here: */

    if (opt_branch) {
      if (reloctype==REL_PC &&
          (op.type==BD || op.type==BDM || op.type==BDP)) {
        if (val<-0x4000000LL || val>0x3ffffffLL) {
          /* "B<cc>" branch destination out of range, convert into
             a "B<!cc> ; B" combination */
          if (insn != NULL) {
            negate_bo_cond(insn);
            *insn = insertcode(*insn,15,ppcop);  /* B<!cc> $+15 */
            insn++;
            *insn = B(18,0,0);  /* set B instruction opcode */
            val -= 5;
          }
          ppcop = &powerpc_operands[LI];  /* set oper. for B instruction */
          isize = 10;
        }
      }
    }

    if (ppcop->flags & OPER_PARENS) {
      if (op.basereg) {
        /* a load/store instruction d(Rn) carries basereg in current op */
        taddr reg;

        if (db!=NULL && op.mode==OPM_NONE && op.attr==REL_NONE) {
          if (eval_expr(op.basereg,&reg,sec,pc)) {
            if (reg == sdreg)  /* is it a small data reference? */
              fix_reloctype(db,REL_SD);
            else if (reg == sd2reg)  /* EABI small data 2 */
              fix_reloctype(db,REL_PPCEABI_SDA2);
          }
        }

        /* write displacement */
        if (insn != NULL) {
          range_check(val,ppcop,db);
          *insn = insertcode(*insn,val,ppcop);
        }

        /* move to next operand type to handle base register */
        op.type = mnemo->operand_type[++i];
        ppcop = &powerpc_operands[op.type];
        op.attr = REL_NONE;
        op.mode = OPM_NONE;
        op.value = op.basereg;
        if (!eval_expr(op.value,&val,sec,pc))
          if (insn != NULL) {
          	printf("2: err found\n");
            cpu_error(2);  /* constant integer expression required */
          }
      }
      else if (insn != NULL)
        cpu_error(14);  /* missing base register */
    }

    /* write val (register, immediate, etc.) */
    if (insn != NULL) {
      range_check(val,ppcop,db);
      *insn = insertcode(*insn,val,ppcop);
    }
  }

  return isize;
}


size_t instruction_size(instruction *ip,section *sec,taddr pc)
/* Calculate the size of the current instruction; must be identical
   to the data created by eval_instruction. */
{
  /* determine optimized size, when needed */
//  if (opt_branch)
//    return eval_operands(ip,sec,pc,NULL,NULL);

  /* otherwise an instruction is always 5 bytes */
  return 5;
}


dblock *eval_instruction(instruction *ip,section *sec,taddr pc)
/* Convert an instruction into a DATA atom including relocations,
   when necessary. */
{
  dblock *db = new_dblock();
  uint64_t insn[6];

	got_break = 0;
  if (db->size = eval_operands(ip,sec,pc,insn,db)) {
    unsigned char *d = db->data = mymalloc(db->size);
    int i;

    for (i=0; i<db->size/5; i++) {
    	if (i==db->size/5-1 && got_break) {
    		insn[i] |= 0x8000000000LL;
    	}
      d = setval(0,d,5,insn[i]);
    }
  }

  return db;
}


dblock *eval_data(operand *op,size_t bitsize,section *sec,taddr pc)
/* Create a dblock (with relocs, if necessary) for size bits of data. */
{
  dblock *db = new_dblock();
  taddr val;
  tfloat flt;

  if ((bitsize & 7) || bitsize > 64)
    cpu_error(9,bitsize);  /* data size not supported */
  if (!OP_DATA(op->type))
    ierror(0);

  db->size = bitsize >> 3;
  db->data = mymalloc(db->size);

  if (type_of_expr(op->value) == FLT) {
    if (!eval_expr_float(op->value,&flt))
      general_error(60);  /* cannot evaluate floating point */

    switch (bitsize) {
      case 32:
        conv2ieee32(1,db->data,flt);
        break;
      case 64:
        conv2ieee64(1,db->data,flt);
        break;
      default:
        cpu_error(10);  /* data has illegal type */
        break;
    }
  }
  else {
    val = make_reloc(get_reloc_type(op),op,sec,pc,&db->relocs);

    switch (db->size) {
      case 1:
        db->data[0] = val & 0xff;
        break;
      case 2:
      case 4:
      case 8:
        setval(ppc_endianess,db->data,db->size,val);
        break;
      default:
        ierror(0);
        break;
    }
  }

  return db;
}


operand *new_operand()
{
  operand *new = mymalloc(sizeof(*new));
  new->type = -1;
  new->mode = OPM_NONE;
  return new;
}


static void define_regnames(void)
{
  char r[4];
  int i;

  for (i=0; i<64; i++) {
    sprintf(r,"r%d",i);
    set_internal_abs(r,(taddr)i);
    r[0] = 'p';
    set_internal_abs(r,(taddr)i);
  }
  for (i=0; i<8; i++) {
    sprintf(r,"cr%d",i);
    set_internal_abs(r,(taddr)i);
  }
  set_internal_abs("prsave",256);
  set_internal_abs("a0",3);
  set_internal_abs("a1",4);
  set_internal_abs("sp",63);
  set_internal_abs("fp",62);
  set_internal_abs("lr",1);
}


int init_cpu()
{
  if (regnames)
    define_regnames();
  return 1;
}


int cpu_args(char *p)
{
  int i;

  abits = 32;
  if (strncmp(p, "-abits=", 7)==0) {
  	abits = atoi(&p[7]);
  	if (abits < 16)
  		abits = 16;
  	else if (abits > 64)
  		abits = 64;
  	return (1);
  }
  if (!strncmp(p,"-m",2)) {
    p += 2;
    if (!strcmp(p,"pwrx") || !strcmp(p,"pwr2"))
      cpu_type = CPU_TYPE_POWER | CPU_TYPE_POWER2 | CPU_TYPE_32;
    else if (!strcmp(p,"pwr"))
      cpu_type = CPU_TYPE_POWER | CPU_TYPE_32;
    else if (!strcmp(p,"601"))
      cpu_type = CPU_TYPE_601 | CPU_TYPE_PPC | CPU_TYPE_32;
    else if (!strcmp(p,"ppc") || !strcmp(p,"ppc32") || !strncmp(p,"60",2) ||
             !strncmp(p,"75",2) || !strncmp(p,"85",2))
      cpu_type = CPU_TYPE_PPC | CPU_TYPE_32;
    else if (!strcmp(p,"ppc64") || !strcmp(p,"620"))
      cpu_type = CPU_TYPE_PPC | CPU_TYPE_64;
    else if (!strcmp(p,"7450"))
      cpu_type = CPU_TYPE_PPC | CPU_TYPE_7450 | CPU_TYPE_32 | CPU_TYPE_ALTIVEC;
    else if (!strncmp(p,"74",2) || !strcmp(p,"avec") || !strcmp(p,"altivec"))
      cpu_type = CPU_TYPE_PPC | CPU_TYPE_32 | CPU_TYPE_ALTIVEC;
    else if (!strcmp(p,"403"))
      cpu_type = CPU_TYPE_PPC | CPU_TYPE_403 | CPU_TYPE_32;
    else if (!strcmp(p,"405"))
      cpu_type = CPU_TYPE_PPC | CPU_TYPE_403 | CPU_TYPE_405 | CPU_TYPE_32;
    else if (!strncmp(p,"44",2) || !strncmp(p,"46",2))
      cpu_type = CPU_TYPE_PPC | CPU_TYPE_440 | CPU_TYPE_BOOKE | CPU_TYPE_ISEL
                 | CPU_TYPE_RFMCI | CPU_TYPE_32;
    else if (!strcmp(p,"821") || !strcmp(p,"850") || !strcmp(p,"860"))
      cpu_type = CPU_TYPE_PPC | CPU_TYPE_860 | CPU_TYPE_32;
    else if (!strcmp(p,"e300"))
      cpu_type = CPU_TYPE_PPC | CPU_TYPE_E300 | CPU_TYPE_32;
    else if (!strcmp(p,"e500"))
      cpu_type = CPU_TYPE_PPC | CPU_TYPE_E500 | CPU_TYPE_BOOKE | CPU_TYPE_ISEL
                 | CPU_TYPE_SPE | CPU_TYPE_EFS | CPU_TYPE_PMR | CPU_TYPE_RFMCI
                 | CPU_TYPE_32;
    else if (!strcmp(p,"booke"))
      cpu_type = CPU_TYPE_PPC | CPU_TYPE_BOOKE;
    else if (!strcmp(p,"com"))
      cpu_type = CPU_TYPE_COMMON | CPU_TYPE_32;
    else if (!strcmp(p,"any"))
      cpu_type |= CPU_TYPE_ANY;
    else
      return 0;
  }
  else if (!strcmp(p,"-no-regnames"))
    regnames = 0;
  else if (!strcmp(p,"-little"))
    ppc_endianess = 0;
  else if (!strcmp(p,"-big"))
    ppc_endianess = 1;
  else if (!strncmp(p,"-sdreg=",7)) {
    i = atoi(p+7);
    if (i>=0 && i<=63)
      sdreg = i;
    else
      cpu_error(13);  /* not a valid register */
  }
  else if (!strncmp(p,"-sd2reg=",8)) {
    i = atoi(p+8);
    if (i>=0 && i<=63)
      sd2reg = i;
    else
      cpu_error(13);  /* not a valid register */
  }
  else if (!strcmp(p,"-opt-branch"))
    opt_branch = 1;
  else
    return 0;

  return 1;
}
