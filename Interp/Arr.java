package Interp;

// Create a new array of the given size filled with the given value
public class Arr extends Statement {
    Operand dest;
    Operand size;
    Operand src;
    int intSize;

    public Arr(Operand d, Operand s, Operand sr, int recordSize) {
        dest = d;
        size = s;
        src = sr;
	intSize = recordSize;
    }

    public String string() { return "  arr " + dest.string() + ", " +
                                 size.string() + ", " +
                                 src.string(); }

    public Statement execute(Environment e) throws InterpException {
        Block b = new Block(((INT)(size.get(e))).value(), src.get(e));
        dest.set(e, b);
        return next;
    }    
    
    
    public String mips()
    {
      
      int sizeOfRec = intSize;
      int increment = sizeOfRec;
      
      if(increment == 0)
	{increment = 4;}
      
      StringBuffer output = new StringBuffer("# Arr::mips() begin\n");

      output.append(size.mipsGet("$t7") + "\n");
      output.append("addi $t6, $zero, " + increment + "\n"); // $t6 = sizeOfRec
      
      output.append("mul $a0, $t7, $t6\n"); // find total length
      output.append("li $v0, 9\n"); // 9 == sbrk
      output.append("syscall\n");
      output.append("add $t7, $a0, $v0\n"); // address of last word in array + 1
      
      output.append(src.mipsGet("$t4") + "\n");

      
      Label top = new Label();
      Label copyTop = new Label();
      
      output.append("move $t0, $v0\n"); // outer loop through array
      output.append(top.mips());
      
      if(sizeOfRec != 0)
	{
        output.append("move $t1, $zero\n"); // inner loop through words of rec
        output.append(copyTop.mips());
	
	output.append("add $s0, $t1, $t4\n");
	output.append("lw $t2, 0($s0)\n");
	
        //output.append("lw $t2, $t1($t4)\n");
        output.append("addi $v0, $v0, " + sizeOfRec + "\n");
	
	output.append("add $s0, $t1, $t0\n");
	output.append("sw $t2, 0($s0)\n");
	
        //output.append("sw $t2, $t1($t0)\n");
        output.append("blt $t1, $t6, " + copyTop.mipsName() + "\n");
	}
    else
	{output.append("sw $t4, 0($t0)\n");}
	
      output.append("addi $t0, $t0, " + increment + "\n");
      output.append("blt $t0, $t7, " + top.mipsName() + "\n");

	output.append("#Type of operand: " + dest + "\n");

      output.append(dest.mipsSet("$v0") + "\n");
      //output.append("sw $v0, 0($t0)"); // save pointer

      return output.toString();
    }
}
