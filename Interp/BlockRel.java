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
	
	output.append("# mips get in Block Rel.\n");
	
	output.append(offset.mipsGet("$t8") + "\n");
	
	output.append("li $s0, 4\n");
	output.append("sub $sp, $sp, $s0\n");
	output.append("sw $t8, 0($sp)\n");
	
	output.append(base.mipsGet("$t9") + "\n");
	
	output.append("lw $t8, 0($sp)\n");
	output.append("addi $sp, $sp, 4\n");
	
	//new addition.
	output.append("li $s1, 4\n");
	output.append("mul $t8, $t8, $s1\n");
	
	output.append("add $s0, $t8, $t9\n");
	output.append("lw " + regName + ", 0($s0)");
	
	return output.toString();
	}

    public String mipsSet(String regName) 
	{
	StringBuffer output = new StringBuffer();
    
	output.append("# mips set in Block Rel.\n");
    
	output.append("#offset data: " + offset.string() + "\n");
	output.append(offset.mipsGet("$t8") + "\n");

	output.append("li $s0, 4\n");
	output.append("sub $sp, $sp, $s0\n");
	output.append("sw $t8, 0($sp)\n");
	
	output.append(base.mipsGet("$t9") + "\n");
	
	output.append("lw $t8, 0($sp)\n");
	output.append("addi $sp, $sp, 4\n");
	
	//new addition.
	output.append("li $s1, 4\n");
	output.append("mul $t8, $t8, $s1\n");
	
	output.append("add $s0, $t8, $t9\n");
	output.append("sw " + regName + ", 0($s0)\n");
	
	return output.toString();
	}
}
