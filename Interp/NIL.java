package Interp;

public class NIL extends Reference {
    public TigerObj get(int i) throws NilAccessException {
	throw new NilAccessException();
    }

    public String string() { return "<nil>"; }
}
