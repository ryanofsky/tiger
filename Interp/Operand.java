package Interp;

public abstract class Operand {
    /// Store a value in this operand: default signls an error
    public void set(Environment e, TigerObj o) throws InterpException {
	throw new BadSetException();
    }

    /// Read a value from this operand: default signal an error
    public TigerObj get(Environment e) throws InterpException {
	throw new BadGetException();
    }

    /// Return a textual representation of the operand
    public String string() { return "<unknown operand>"; }
   
    /// Return code that places the operand in the given MIPS register
    public String mipsGet(String reg) { return "<illegal operand>"; }

    /// Return code that writes the given MIPS register into the operand
    public String mipsSet(String reg) { return "<illegal operand>"; }
}
