package Interp;

/// Branch on not zero
public class Bnz extends Statement {
    LabelOperand target;
    Operand source;

    public Bnz(LabelOperand t, Operand s) { target = t; source = s; }

    public String string() {
	return "  bnz " + target.string() + ", " + source.string();
    }

    public Statement execute(Environment e) throws InterpException {
	TigerObj o = source.get(e);
	if (o instanceof INT) {
	    if ( ((INT)o).value() != 0 )
		return target.value();
	    else
		return next;
	} else {
	    throw new TypeErrorException(string());
	}
    }
}
