package Interp;

public abstract class Reference extends TigerObj {
    public abstract TigerObj get(int i) throws NilAccessException;
}
