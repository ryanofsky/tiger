package Interp;

public class IntConstant extends Operand {
    int v;
    public IntConstant(int i) { v = i; }

    public TigerObj get(Environment e) { return new INT(v); }

    public String string() { return Integer.toString(v,10); }

    public String mipsGet(String reg) {
	return "  li " + reg + ", " + Integer.toString(v,10);
    }
}
