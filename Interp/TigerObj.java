package Interp;

public abstract class TigerObj {
    /// Copy operation: most objects simply return an alias
    public TigerObj copy() { return this; }

    public String string() { return "<unknown object>"; }
}
