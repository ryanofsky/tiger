package Interp;

public class INT extends TigerObj {
    int v;
    public INT(int i) { v = i; }

    public int value() { return v; }

    /// Copy operation for integer copies the value, not the pointer
    public TigerObj copy() { return new INT(v); }

    public String string() { return Integer.toString(v, 10); }

}
