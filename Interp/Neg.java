package Interp;

public class Neg extends Statement {
    Operand source, dest;

    public Neg(Operand d, Operand s) { source = s; dest =d; }

    public String string() {
	return "  neg " + dest.string() + ", " + source.string();
    }

    /// Read the source, negate it, write it to the the dest, and return next
    public Statement execute(Environment e) throws InterpException {
	INT o = (INT)(source.get(e));
	dest.set(e, new INT(-o.value()));
	return next;
    }
    
    public String mips()
	{
	StringBuffer output = new StringBuffer(source.mipsGet("$t0") + "\n");
	output.append("neg $t0, $t0\n");
	output.append(dest.mipsSet("$t0") + "\n");
	return output.toString();
	}
    
    
}
