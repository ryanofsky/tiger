package Interp;

/// Root class for all interpreter-related exceptions
public abstract class InterpException extends Exception {
    public InterpException(String s) {
	super(s);
    }
}
