package Interp;

/// Add or remove elements on the current stack
public class Psh extends Statement {

    int size;

    public Psh(int s) { size = s; }

    public String string() { return "  psh " + Integer.toString(size, 10); }

    public Statement execute(Environment e) {
	e.stack.adjust(size);
	return next;
    }

    public String mips() {
	return "  subu $sp, " + Integer.toString(size*4, 10);
    }
}
