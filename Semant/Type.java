package Semant;

public abstract class Type {
    /// Returns the actual type this refers to (only interesting for aliases)
    public Type actual() { return this; }         

    /// True if this type can be coerced to the given one
    public boolean coerceTo(Type t) { return false; }
}

