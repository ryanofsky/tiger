package Interp;

public class IntConstant extends Operand {
    int v;
    public IntConstant(int i) { v = i; }

    public TigerObj get(Environment e) { return new INT(v); }

    public String string() { return Integer.toString(v,10); }
}
