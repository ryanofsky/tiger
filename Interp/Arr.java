package Interp;

// Create a new array of the given size filled with the given value
public class Arr extends Statement {
    Operand dest;
    Operand size;
    Operand src;

    public Arr(Operand d, Operand s, Operand sr) {
	dest = d;
	size = s;
	src = sr;
    }

    public String string() { return "  arr " + dest.string() + ", " +
				 size.string() + ", " +
				 src.string(); }

    public Statement execute(Environment e) throws InterpException {
	Block b = new Block(((INT)(size.get(e))).value(), src.get(e));
	dest.set(e, b);
	return next;
    }    

}
