package Interp;

public class TypeErrorException extends InterpException {
    public TypeErrorException(String s) {
	super("Invalid types for operation " + s);
    }
}
