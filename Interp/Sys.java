package Interp;

/// System call instruction
public class Sys extends Statement {
    public final static int PRINT = 0;
    public final static int PRINTI = 1;
    public final static int FLUSH = 2;
    public final static int GETCHAR = 3;
    public final static int ORD = 4;
    public final static int CHR = 5;
    public final static int SIZE = 6;
    public final static int SUBSTRING = 7;
    public final static int CONCAT = 8;
    public final static int NOT = 9;
    public final static int EXIT = 10;

    int number;

    public Sys(int n) { number = n; }

    public String string() { return "  sys " + Integer.toString(number, 10); }

    public Statement execute(Environment e) {

	switch (number) {
	case PRINT:
	case PRINTI: {
	    System.out.print( e.stack.get(-1).string() );
	    break;
	}
	    // FIXME: other standard library calls missing
	}
       
	return next;
    }

    public String mips() 
	{
	StringBuffer output = new StringBuffer();
	Label repeatLoop = null;
	Label doneCounting = null;
	String subCode = "";
	switch (number) 
	    {
	    case PRINT:
		output.append("lw $a0, 4($fp) # Get the string's address\n");
		output.append("li $v0, 4      # code for print_string\n");
		output.append("syscall\n");
		return output.toString();
	    case PRINTI:
		output.append("lw $a0, 4($fp) # Get the string's address\n");
		output.append("li $v0, 1      # code for print_integer\n");
		output.append("syscall\n");
		return output.toString();
	    case FLUSH:
		return "";
	    case GETCHAR:
		//allocate a buffer.
		output.append("li $a0, 4\n"); // find total length
		output.append("li $v0, 9\n"); // 9 == sbrk
		output.append("syscall\n");
		
		output.append("move $a0, $v0\n"); //copy address to $a0.
		output.append("li $a1, 4\n"); //the length of the buffer.

		output.append("li $v0, 8     # code for read string.\n");
		output.append("syscall\n");

		output.append("lw $t1, $a0\n"); //read in our buffer (first four bytes) from ram.
		output.append("andi $t0, $t1, $0xff000000\n"); //select out the first byte in the buffer.
		//output.append("srl $t0, $t0, 24\n"); //shift down.
		
		output.append("sv $t0, 4($fp)\n"); //save the data to the stack.
		
		return output.toString();
	    case ORD:
		output.append("lw $t0, 4($fp) # Suck in the first word of the string.\n");
		output.append("andi $t0, $t1, $0xff000000\n"); //select out the first byte in the buffer.
		output.append("srl $t0, $t0, 24\n"); //shift down the string's first character.
		output.append("li $t1, 0\n");
		output.append("seq $t3, $t0, $t1\n"); //if our character is null, set $t3 to 1, otherwise 0.
		output.append("add $t0, $t0, $t3\n"); //if our character is null, set to 1.
		
		output.append("sv $t0, 4($fp)\n"); //save the data to the stack.
		return output.toString();
	    case CHR:
		Label exit = new Label();
		Label branchDone = new Label();

		output.append("lw $t0, 4($fp) # Suck in the integer.\n");
		output.append("li $t1, 10\n");
		output.append("li $t2, 0\n");
		
		output.append("bgt $t0, $t1, " + exit.mipsName() + "\n");
		output.append("blt $t0, $t2, " + exit.mipsName() + "\n");
		
		output.append("addi $t0, 48\n");
		output.append("sll $t0, $t0, 24\n");
		output.append("andi $t0, $t0, $0xff000000\n"); //select out the first byte in the buffer.
		
		output.append("b " + branchDone.mipsName() + "\n");
		
		//now for the exit code.
		output.append(exit.mips());
		output.append("li $v0, 10     # code for exit.\n");
		output.append("syscall\n");
	    
		//now continue code.
		output.append(branchDone.mips());
		output.append("sv $t0, 4($fp)\n"); //save the data to the stack.
	    
		return output.toString();
	    case SIZE:
		repeatLoop = new Label();
		doneCounting = new Label();
	    
		subCode = "beqz $t6, " + doneCounting.mipsName() + "\n";
		subCode += "addi $t2, $t2, 1\n"; //increment the count.
	    
		output.append("lw $t0, 4($fp) # Suck in the String address.\n");
		output.append("li $t1, 0\n");
		output.append("li $t2, 0\n");
		
		//begin the loop.
		output.append(repeatLoop.mips());
		output.append("lw $t5, $t1($t0)\n");
	    
		output.append("andi $t6, $t5, 0xff000000\n");
		output.append(subCode);
		output.append("andi $t6, $t5, 0xff0000\n");
		output.append(subCode);
		output.append("andi $t6, $t5, 0xff00\n");
		output.append(subCode);
		output.append("andi $t6, $t5, 0xff\n");
		output.append(subCode);
		
		output.append("addi $t1, $t1, 4\n");
		output.append("b " + repeatLoop.mipsName() + "\n");
		
		output.append(doneCounting + ":\n");
		output.append("sv $t2, 4($fp)\n"); //save the data to the stack.
		
		return output.toString();
	    case SUBSTRING:
		Label copyNext = new Label();
		Label endOfString = new Label();
	    
		output.append("lw $t0, 4($fp) # Suck in the String address.\n");
		output.append("lw $t1, 8($fp) # Suck in the starting character.\n");
		output.append("lw $t2, 12($fp) # Suck in the number of characters.\n");
		
		output.append("addi $a0, $t2, 1"); //we need room for the ending null.
		output.append("li $v0, 9\n"); // 9 == sbrk
		output.append("syscall\n");
		
		output.append("move $t5, $v0\n # pointer into destination string."); //copy address to $t5.
		output.append("add $t6, $t5, $zero\n # address of destination string."); //copy to $t6
		
		output.append("add $t0, $t0, $t1\n #address of first needed byte."); //address of the first byte we need.
	    
		output.append(copyNext.mips());

		output.append("beqz $t2, " + endOfString + "\n");
		output.append("lb $t3, $t0");
		output.append("sb $t3, $t5\n");
		
		output.append("subi $t2, $t2, 1\n");
		output.append("addi $t5, $t5, 1\n");
		output.append("addi $t0, $t0, 1\n");
		
		output.append("b " + copyNext.mipsName() + "\n");
		
		//we're done.....
		output.append(endOfString.mips());
		output.append("sb $zero, $t5\n"); //null terminate.
		output.append("sv $t6, 4($fp)\n"); //save the data to the stack.

		return output.toString();
	    case CONCAT:
		Label firstLoop = new Label();
		Label secondLoop = new Label();
		
		subCode = "beqz $t6, " + doneCounting.mipsName() + "\n";
		subCode += "addi $t2, $t2, 1\n"; //increment the count.

		output.append("lw $t0, 4($fp) # Suck in the String1 address.\n");
		output.append("lw $t1, 8($fp) # Suck in the String2 address.\n");
		
		output.append("add $t9, $t1, $zero\n"); //save the second string address for the moment.
		output.append("add $t8, $t0, $zero\n");

	    
		//first figure out the size...
		for(int i = 0; i < 2; i++)
		    {
		    repeatLoop = new Label();
		    doneCounting = new Label();

		    output.append("li $t1, 0\n");
		    output.append("li $t2, 0\n");
		
		    //begin the loop.
		    output.append(repeatLoop + ":\n");
		    output.append("lw $t5, $t1($t0)\n");
		
		    output.append("andi $t6, $t5, 0xff000000\n");
		    output.append(subCode);
		    output.append("andi $t6, $t5, 0xff0000\n");
		    output.append(subCode);
		    output.append("andi $t6, $t5, 0xff00\n");
		    output.append(subCode);
		    output.append("andi $t6, $t5, 0xff\n");
		    output.append(subCode);
		    
		    output.append("addi $t1, $t1, 4\n");
		    output.append("b " + repeatLoop + "\n");
		    
		    output.append(doneCounting + ":\n");

		    if(i == 0)
			{
			output.append("add $t7, $t2, $zero\n");
			output.append("add $t0, $t9, $zero\n");
			}
		    }
	    
	    
	    
	    
	    
		return output.toString();
	    case NOT:
	    case EXIT:
		output.append("li $v0, 10     # code for exit.\n");
		output.append("syscall\n");
	    default:
		return "# not handled";
	    }
	}
}
