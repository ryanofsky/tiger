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

    public String mips() {
	return
	    "  move $sp, $fp     # Restore sp\n" +
	    "  lw   $fp, -8($sp) # Restore fp\n" +
	    "  lw   $ra, -0($sp) # Restore ra\n" +
	    "  jr   $ra          # Return to caller";
    }

}
