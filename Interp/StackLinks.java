package Interp;

/// A variable/temporary/argument on the stack in this or a parent scope

public class StackLinks extends FrameRel {

    // Number of static links to follow
    int depth;

    public StackLinks(int o, int d) { super(o); depth = d; }

    public String string() {
	return Integer.toString(depth,10) + "*" + super.string();
    }

    Activation offsetRecord(Environment e) {
	Activation a = e.stack;
	for (int i = 0 ; i < depth ; i++ ) a = a.staticLink;
	return a;
    }

    public TigerObj get(Environment e) throws InterpException {
	return offsetRecord(e).get(offset);
    }

    public void set(Environment e, TigerObj o) throws InterpException {
	offsetRecord(e).set(offset, o);
    }
}
