package Interp;

public class Binop extends Statement {

    /// Instruction constants
    public final static int ADD = 0;
    public final static int SUB = 1;
    public final static int MUL = 2;
    public final static int DIV = 3;
    public final static int EQU = 4; /// Equals
    public final static int NEQ = 5; /// Not equal
    public final static int LT  = 6; /// Less than
    public final static int LEQ = 7; /// Less than or equal
    public final static int GT  = 8; /// Greater than
    public final static int GEQ = 9; /// Greater than or equal

    final static String opcodes[] =
    { "add", "sub", "mul", "div", "equ", "neq", "lt ", "leq", "gt ", "geq" };

    int opcode;
    Operand source1, source2, dest;
    boolean isString;

    public Binop(int op, Operand d, Operand s1, Operand s2, boolean doingStrings) {
	isString = doingStrings;
	opcode = op;
	dest = d;
	source1 = s1;
	source2 = s2;
    }

    public String string() {
	return "  " + opcodes[opcode] + " " + dest.string() + ", " +
	    source1.string() + ", " + source2.string();
    }

    public Statement execute(Environment e) throws InterpException {
	TigerObj o1 = source1.get(e);
	TigerObj o2 = source2.get(e);

	switch (opcode) {
	case ADD:
	case SUB:
	case MUL:
	case DIV: {
	    if (o1 instanceof INT && o2 instanceof INT) {
		int v1 = ((INT)o1).value();
		int v2 = ((INT)o2).value();
		int result = 0;
		switch (opcode) {
		case ADD: result = v1 + v2; break;
		case SUB: result = v1 - v2; break;
		case MUL: result = v1 * v2; break;
		case DIV: result = v1 / v2; break;
		}
		dest.set(e, new INT(result));
	    } else {
		throw new TypeErrorException(string());
	    };
	    break;
	}	

	case EQU:
	case NEQ: {
	    boolean result;
	    if (o1 instanceof INT && o2 instanceof INT)
		result = ((INT)o1).value() == ((INT)o2).value();
	    else if (o1 instanceof STRING && o2 instanceof STRING)
		result = ((STRING)o1).value().equals(((STRING)o2).value());
            else if (o1 instanceof NIL || o2 instanceof NIL)
                result = (o1 instanceof NIL && o2 instanceof NIL);
	    else
		result = o1 == o2;
	    if (opcode == NEQ) result = !result;
	    dest.set(e, new INT(result ? 1 : 0));
	    break;
	}

	case LT:
	case LEQ:	
	case GT:
	case GEQ: {
	    if (o1 instanceof INT && o2 instanceof INT) {
		int v1 = ((INT)o1).value();
		int v2 = ((INT)o2).value();       
		boolean result = false;
		switch (opcode) {
		case LT: result = v1 < v2; break;
		case LEQ: result = v1 <= v2; break;
		case GT: result = v1 > v2; break;
		case GEQ: result = v1 >= v2; break;
		}
		dest.set(e, new INT(result ? 1 : 0));
	    } else if (o1 instanceof STRING && o2 instanceof STRING) {
		String v1 = ((STRING)o1).value();
		String v2 = ((STRING)o2).value();
		int comparison = v1.compareTo(v2);
		boolean result = false;
		switch (opcode) {
		case LT: result = comparison < 0; break;
		case LEQ: result = comparison <= 0; break;
		case GT: result = comparison > 0; break;
		case GEQ: result = comparison >= 0; break;
		}
		dest.set(e, new INT(result ? 1 : 0));
	    } else
		throw new TypeErrorException(string());
	    break;
	}

	default:
	    throw new UnknownOpcodeException(opcode, string());	
	};

	return next;
    }

    final static String mipsOpcodes[] =
    { "add", "sub", "mul", "div", "seq", "sne", "slt", "sle", "sgt", "sge" };

    public String mips() {

	StringBuffer output = new StringBuffer(source1.mipsGet("$t0") + "\n");
	output.append(source2.mipsGet("$t1") + "\n");

	if(isString)
	    {
	    Label branchOut = new Label();
	    Label branchFalse = new Label();
	    Label branchRepeat = new Label();
	    Label branchTrue = new Label();
	    
	    String falseTest = null;
	    
	    switch(opcode)
		{
		case EQU:
		    falseTest = "bne $t7, $t8, " + branchFalse.mipsName() + "\n";
		    falseTest += "beqz $t7, " + branchTrue.mipsName() + "\n";
		    break;
		case NEQ:
		    falseTest = "bne $t7, $t8, " + branchTrue.mipsName() + "\n";
		    falseTest += "beqz $t7, " + branchFalse.mipsName() + "\n";
		    break;
		case LT:
		    falseTest = "bgt $t7, $t8, " + branchFalse.mipsName() + "\n";
		    falseTest += "blt $t7, $t8, " + branchTrue.mipsName() + "\n";
		    falseTest += "beqz $t8, " + branchFalse.mipsName() + "\n";
		    break;
		case LEQ:
		    falseTest = "bgt $t7, $t8, " + branchFalse.mipsName() + "\n";
		    falseTest += "blt $t7, $t8, " + branchTrue.mipsName() + "\n";
		    falseTest += "beqz $t8, " + branchTrue.mipsName() + "\n";
		    break;
		case GT:
		    falseTest = "blt $t7, $t8, " + branchFalse.mipsName() + "\n";
		    falseTest += "bgt $t7, $t8, " + branchTrue.mipsName() + "\n";
		    falseTest += "beqz $t8, " + branchFalse.mipsName() + "\n";
		    break;
		case GEQ:
		    falseTest = "blt $t7, $t8, " + branchFalse.mipsName() + "\n";
		    falseTest += "bgt $t7, $t8, " + branchTrue.mipsName() + "\n";
		    falseTest += "beqz $t8, " + branchTrue.mipsName() + "\n";
		    break;
		default:
		    throw new IllegalStateException("Bad opcode: " + opcode);	
		}
	    
	    
	    output.append(branchRepeat.mips());
	    output.append("li $t2, 0\n");
	    
	    //begin the loop.
	    output.append("lw $t5, $t2($t0)\n");
	    output.append("lw $t6, $t2($t0)\n");
	    
	    output.append("andi $t7, $t5, 0xff000000\n");
	    output.append("andi $t8, $t6, 0xff000000\n");
	    output.append(falseTest);
	    
	    output.append("andi $t7, $t5, 0xff0000\n");
	    output.append("andi $t8, $t6, 0xff0000\n");
	    output.append(falseTest);
	    
	    output.append("andi $t7, $t5, 0xff00\n");
	    output.append("andi $t8, $t6, 0xff00\n");
	    output.append(falseTest);
	    
	    output.append("andi $t7, $t5, 0xff\n");
	    output.append("andi $t8, $t6, 0xff\n");
	    output.append(falseTest);
	    
	    //now loop again.
	    output.append("addi $t2, $t2, 4\n");
	    output.append("b " + branchRepeat.mipsName() + "\n");
	    
	    //now for the return statements.
	    output.append(branchFalse.mips());
	    output.append("li $t0, 0\n");
	    output.append("b " + branchOut.mipsName() + "\n");
	    
	    output.append(branchTrue.mips());
	    output.append("li $t0, 1\n");
	    
	    output.append(branchOut.mips());
	    }
	else
	    {output.append("  " + mipsOpcodes[opcode] + " $t0, $t0, $t1\n");}
	    
	output.append(dest.mipsSet("$t0"));
	    
	// FIXME: This doesn't do the right thing for comparing strings
	return output.toString();
    }
}
