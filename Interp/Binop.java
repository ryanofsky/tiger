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

    public Binop(int op, Operand d, Operand s1, Operand s2) {
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
		case LT: result = comparison < 0;
		case LEQ: result = comparison <= 0;
		case GT: result = comparison > 0;
		case GEQ: result = comparison >= 0;
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
}
