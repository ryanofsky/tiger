package Interp;

// Create a new, empty record
public class Rec extends Statement {
    Operand dest;
    int size;

    public Rec(Operand d, int s) { dest = d; size = s; }

    public String string() { return "  rec " + dest.string() + ", " +
				 Integer.toString(size, 10); }

    public Statement execute(Environment e) throws InterpException {
	Block b = new Block(size);
	dest.set(e, b);
	return next;
    }    
    
    
    
    
    public String mips()
	{
	  StringBuffer output = new StringBuffer();
	  output.append(dest.mipsGet("$t0"));
	  output.append("la $a0, " + size + "\n");
	  output.append("li $v0, 9\n"); // 9 == sbrk
	  output.append("syscall\n");
	  return output.toString();
	}
}
