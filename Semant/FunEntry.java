package Semant;

public class FunEntry extends Entry {
    public RECORD formals;
    public Type result;

    public FunEntry(RECORD f, Type r) { formals = f; result = r; }
}
