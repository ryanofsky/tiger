package Interp;

public class NilConstant extends Operand {
    public TigerObj get(Environment e) { return new NIL(); }

    public String string() { return "nil"; }
}
