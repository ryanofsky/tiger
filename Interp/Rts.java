package Interp;

/// Return-from-subroutine

public class Rts extends Statement {

    public String string() { return "  rts"; }

    public Statement execute(Environment e) {
	// Fetch the return address
	Statement n = e.stack.returnAddress;

	// Unlink the current stack frame
	e.stack = e.stack.dynamicLink;

	return n;
    }

}
