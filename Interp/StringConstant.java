package Interp;

public class StringConstant extends Operand {
    String v;
    public StringConstant(String s) { v = s; }

    public TigerObj get(Environment e) { return new STRING(v); }

    public String string() { return "\"" + v + "\""; }
}
