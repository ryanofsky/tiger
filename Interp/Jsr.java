package Interp;

/// Jump-to-subroutine

public class Jsr extends Statement {

    LabelOperand dest;

    /// Number of static links to traverse to locate the new static link
    int depth;

    public Jsr(LabelOperand dst, int dep) { dest = dst; depth = dep; }

    public String string() {
	return "  jsr " + dest.string() + ", " + Integer.toString(depth, 10);
    }

    public Statement execute(Environment e) {

	// Follow as many static links as prescribed to get the new one
	Activation sl = e.stack;
	for ( int d = 0 ; d < depth ; d++ ) sl = sl.staticLink;

	e.stack = new Activation(sl, e.stack, next);
	return dest.value();
    }

    public String mips() {

	String links;

	// Generate code that puts the proper static link into a0.
	// Follow as many static links as given by the depth.

	links = "  move $a0, $fp\n";
	for ( int i = 0 ; i < depth ; i++ )
	    links = links + "  lw $a0, -4($a0)\n";
	return links + "  jal " + dest.string();
    }

}
