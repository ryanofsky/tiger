package Interp;

public class UnknownOpcodeException extends InterpException {
    public UnknownOpcodeException(int op, String s) {
	super("Unknown opcode " + Integer.toString(op, 10) + " in " + s);
    }
}
