package Interp;

public class BadGetException extends InterpException {
    public BadGetException() {
	super("Erroneous read of an operand");
    }
}
