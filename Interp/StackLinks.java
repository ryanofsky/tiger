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

    public String mipsGet(String reg) {
	return links(reg) +
	    "  lw " + reg + ", " +
	    Integer.toString(-4*offset-(offset>=0?12:0)) + "(" + reg + ")";
    }

    public String mipsSet(String reg) {
	return links(reg) +
	    "  sw " + reg + ", " +
	    Integer.toString( -4*offset-(offset>=0?12:0)) + "(" + reg + ")";
    }

    String links(String reg) {
	String l = "  mov " + reg + ", $fp\n";
	for ( int i = 0 ; i < depth ; i++ )
	    l = l + "  lw " + reg + ", -4(" + reg + ")\n";
	return l;
    }
}
