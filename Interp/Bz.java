package Interp;

/// Branch on zero
public class Bz extends Statement {
    LabelOperand target;
    Operand source;

    public Bz(LabelOperand t, Operand s) { target = t; source = s; }

    public String string() {
	return "  bz  " + target.string() + ", " + source.string();
    }

    public Statement execute(Environment e) throws InterpException {
	TigerObj o = source.get(e);
	if (o instanceof INT) {
	    if ( ((INT)o).value() == 0 )
		return target.value();
	    else
		return next;
	} else {
	    throw new TypeErrorException(string());
	}
    }
    
    
    
    
    public String mips()
	{
	StringBuffer output = new StringBuffer(source.mipsGet("$t0"));
	output.append("beqz $t0, " + target.string() + "\n");
	return output.toString();
	}
    
}
