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
}
