package Interp;

public class Mov extends Statement {
    Operand source, dest;

    public Mov(Operand d, Operand s) { source = s; dest =d; }

    public String string() {
	return "  mov " + dest.string() + ", " + source.string();
    }

    /// Read the source, write it to the the dest, and return the next
    public Statement execute(Environment e) throws InterpException {
	TigerObj o = source.get(e).copy();
	dest.set(e, o);
	return next;
    }
}
