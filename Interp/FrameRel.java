package Interp;

/// A variable/temporary/argument in the current activation record

public class FrameRel extends Operand {

    // Offset in activation record
    int offset;

    public FrameRel(int o) { offset = o; }

    public String string() {
	return "fp(" + Integer.toString(offset,10) + ")";
    }

    public TigerObj get(Environment e) throws InterpException {
	return e.stack.get(offset);
    }

    public void set(Environment e, TigerObj o) throws InterpException {
	e.stack.set(offset, o);
    }
}
