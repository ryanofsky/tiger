package Interp;

// Access into a block
public class BlockRel extends Operand {

    /// A block, typically on the stack
    Operand base;

    /// An integer offset into the block (field in a record or a subscript)
    Operand offset;

    public BlockRel(Operand b, Operand o) {
	base = b;
	offset = o;
    }

    public String string() {
        return base.string() + "[" + offset.string() + "]";
    }    

    public TigerObj get(Environment e) throws InterpException {
	Block b = (Block)(base.get(e));
	INT i = (INT)(offset.get(e));
	return b.get(i.value());
    }

    public void set(Environment e, TigerObj o) throws InterpException {
	Block b = (Block)(base.get(e));
	INT i = (INT)(offset.get(e));
	b.set(i.value(), o);
    }
    
    
    public String mipsGet(String regName) 
	{
	StringBuffer output = new StringBuffer();
	
	output.append(offset.mipsSet("$t8") + "\n");
	
	output.append("subi $sp, $sp, 4\n");
	output.append("sw $t8, $sp\n");
	
	output.append(base.mipsSet("$t9") + "\n");
	
	output.append("lw $t8, $sp\n");
	output.append("addi $sp, $sp, 4\n");
	
	output.append("lw " + regName + ", $t8($t9)");
	
	return output.toString();
	}

    public String mipsSet(String regName) 
	{
	StringBuffer output = new StringBuffer();
	
	output.append(offset.mipsSet("$t8") + "\n");

	output.append("subii $sp, $sp, 4\n");
	output.append("sw $t8, $sp\n");
	
	output.append(base.mipsSet("$t9") + "\n");
	
	output.append("lw $t8, $sp\n");
	output.append("addi $sp, $sp, 4\n");
	
	output.append("sw " + regName + ", $t8($t9)\n");
	
	return output.toString();
	}
}
