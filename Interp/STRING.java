package Interp;

public class STRING extends TigerObj {
    String v;

    public String value() { return v; }
    public STRING(String s) { v = s; }
    public String string() { return v; }
}

