package Interp;

public class NilAccessException extends InterpException {
    public NilAccessException() {
	super("Erroneous attempt to dereference a nil record");
    }
}
