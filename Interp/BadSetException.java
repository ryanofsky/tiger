package Interp;

public class BadSetException extends InterpException {
    public BadSetException() {
	super("Erroneous assignment to an operand");
    }
}
