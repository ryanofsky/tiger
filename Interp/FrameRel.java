package Interp;

/// A variable/temporary/argument in the current activation record

public class FrameRel extends Operand {

    // Offset in activation record
    public int offset;

    public FrameRel(int o) { offset = o; }

    public String string() {
	return "fp(" + Integer.toString(offset,10) + ")";
    }

    public TigerObj get(Environment e) throws InterpException {
	return e.stack.get(offset);
    }

    public void set(Environment e, TigerObj o) throws InterpException {
	e.stack.set(offset, o);
    }

    public String mipsGet(String reg) 
	{
	StringBuffer output = new StringBuffer("#In FrameRel mipsGet\n");
	
	output.append("  lw " + reg + ", ");
	output.append(Integer.toString( -4*offset-(offset>=0?12:0)) + "($fp)");
	
	return output.toString();
    }

    public String mipsSet(String reg) 
	{
	StringBuffer output = new StringBuffer("#In FrameRel mipsSet\n");
	output.append("  sw " + reg + ", ");
	output.append(Integer.toString( -4*offset-(offset>=0?12:0)) + "($fp)");
	
	return output.toString();
    }
}
