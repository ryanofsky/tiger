package Interp;

public class Ent extends Statement {
    public Ent() {
    
    /*
    try
	{throw new Exception("Tracing.");}
    catch(Exception e)
	{e.printStackTrace();}
    */
    
    }

    public String string() { return "  ent"; }

    /// Do nothing
    public Statement execute(Environment e) { return next; }

    public String mips() 
    {
	return
	    "  sw  $ra, 0($sp)  # Save return address\n" +
	    "  sw  $a0, -4($sp) # Initialize static link\n" +
	    "  sw  $fp, -8($sp) # Save old fp\n" +
	    "  move $fp, $sp    # Set up new fp\n" +
	    "  subu $sp, 12     # Update sp";
    }
}
