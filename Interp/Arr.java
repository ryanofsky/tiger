package Interp;

// Create a new array of the given size filled with the given value
public class Arr extends Statement {
    Operand dest;
    Operand size;
    Operand src;

    public Arr(Operand d, Operand s, Operand sr) {
        dest = d;
        size = s;
        src = sr;
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
      
      int sizeOfRec = 4;
      StringBuffer output = new StringBuffer("# Arr::mips() begin\n");

      output.append(size.mipsGet("$t7"));
      output.append("addi $t6, $zero, " + sizeOfRec + "\n"); // $t6 = sizeOfRec
      
      output.append("multi $a0, $t7," + sizeOfRec + "\n"); // find total length
      output.append("li $v0, 9\n"); // 9 == sbrk
      output.append("syscall\n");
      output.append("add $t7, $a0, $v0\n"); // address of last word in array + 1
      
      output.append(src.mipsGet("$t4"));

      
      Label top = new Label();
      Label copyTop = new Label();
      
      output.append("move $t0, $v0\n"); // outer loop through array
      output.append(top.string() + ":\n");
        output.append("move $t1, $zero\n"); // inner loop through words of rec
        output.append(copyTop.string() + ":\n");
        output.append("load $t2, $t1($t4)\n");
        output.append("addi $v0, $v0, " + sizeOfRec + "\n");
        output.append("sw $t2, $t1($t0)\n");
        output.append("blt $t1, $t6, " + copyTop + "\n");
      output.append("addi $t0, $t0, " + sizeOfRec + "\n");
      output.append("blt $t0, $t7, " + top + "\n");

      output.append(dest.mipsGet("$t0"));
      output.append("sw $v0, $t0"); // save pointer

      return output.toString();
    }
}
