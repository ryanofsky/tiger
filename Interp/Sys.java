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

		output.append("lw $t1, 0($a0)\n"); //read in our buffer (first four bytes) from ram.
		output.append("srl $t1, $t1, 24\n");
		output.append("andi $t1, $t1, 0xff\n"); //select out the first byte in the buffer.
		output.append("sll $t0, $t1, 24\n");
		//output.append("srl $t0, $t0, 24\n"); //shift down.
		
		output.append("sw $t0, 4($fp)\n"); //save the data to the stack.
		
		return output.toString();
	    case ORD:
		output.append("lw $t0, 4($fp) # Suck in the first word of the string.\n");
		output.append("srl $t0, $t0, 24\n"); //shift down the string's first character.
		output.append("li $t1, 0\n");
		output.append("seq $t3, $t0, $t1\n"); //if our character is null, set $t3 to 1, otherwise 0.
		output.append("add $t0, $t0, $t3\n"); //if our character is null, set to 1.
		
		output.append("sw $t0, 4($fp)\n"); //save the data to the stack.
		return output.toString();
	    case CHR:
		Label exit = new Label();
		Label branchDone = new Label();

		output.append("lw $t0, 4($fp) # Suck in the integer.\n");
		output.append("li $t1, 10\n");
		output.append("li $t2, 0\n");
		
		output.append("bgt $t0, $t1, " + exit + "\n");
		output.append("blt $t0, $t2, " + exit + "\n");
		
		output.append("addi $t0, 48\n");
		output.append("sll $t0, $t0, 24\n");
		//output.append("andi $t0, $t0, 0xff000000\n"); //select out the first byte in the buffer.
		
		output.append("b " + branchDone + "\n");
		
		//now for the exit code.
		output.append(exit + ":\n");
		output.append("li $v0, 10     # code for exit.\n");
		output.append("syscall\n");
	    
		//now continue code.
		output.append(branchDone + ":\n");
		output.append("sw $t0, 4($fp)\n"); //save the data to the stack.
	    
		return output.toString();
	    case SIZE:
		Label repeatLoop = new Label();
		Label doneCounting = new Label();
	    
		String subCode = "beqz $t6, " + doneCounting + "\n";
		subCode += "addi $t2, $t2, 1\n"; //increment the count.
	    
		output.append("lw $t0, 4($fp) # Suck in the String address.\n");
		output.append("li $t1, 0\n");
		output.append("li $t2, 0\n");
		
		//begin the loop.
		output.append(repeatLoop + ":\n");
		
		//output.append("lw $t5, $t1($t0)\n");
		output.append("add $s0, $t1, $t0\n");
		output.append("lw $t5, 0($s0)\n");
		//
	    
		output.append("srl $t6, $t5, 24\n");
		output.append("andi $t6, $t6, 0xff\n");
		//output.append("andi $t6, $t5, 0xff000000\n");
		output.append(subCode);
		output.append("srl $t6, $t5, 16\n");
		output.append("andi $t6, $t6, 0xff\n");
		//output.append("andi $t6, $t5, 0xff0000\n");
		output.append(subCode);
		output.append("srl $t6, $t5, 8\n");
		output.append("andi $t6, $t6, 0xff\n");
		//output.append("andi $t6, $t5, 0xff00\n");
		output.append(subCode);
		output.append("andi $t6, $t5, 0xff\n");
		output.append(subCode);
		
		output.append("addi $t1, $t1, 4\n");
		output.append("b " + repeatLoop + "\n");
		
		output.append(doneCounting + ":\n");
		output.append("sw $t2, 4($fp)\n"); //save the data to the stack.
		
		return output.toString();
	    case SUBSTRING:
		Label copyNext = new Label();
		Label endOfString = new Label();
	    
		output.append("lw $t0, 4($fp) # Suck in the String address.\n");
		output.append("lw $t1, 8($fp) # Suck in the starting character.\n");
		output.append("lw $t2, 12($fp) # Suck in the number of characters.\n");
		
		output.append("addi $a0, $t2, 1\n"); //we need room for the ending null.
		output.append("li $v0, 9\n"); // 9 == sbrk
		output.append("syscall\n");
		
		output.append("move $t5, $v0 # pointer into destination string.\n"); //copy address to $t5.
		output.append("add $t6, $t5, $zero # address of destination string.\n"); //copy to $t6
		
		output.append("add $t0, $t0, $t1 #address of first needed byte.\n"); //address of the first byte we need.
	    
		output.append(copyNext + ":\n");

		output.append("beqz $t2, " + endOfString + "\n");
		output.append("lb $t3, 0($t0)\n");
		output.append("sb $t3, 0($t5)\n");
		
		output.append("li $s0, 1\n");
		output.append("sub $t2, $t2, $s0\n");
		output.append("addi $t5, $t5, 1\n");
		output.append("addi $t0, $t0, 1\n");
		
		output.append("b " + copyNext + "\n");
		
		//we're done.....
		output.append(endOfString + ":\n");
		output.append("sb $zero, 0($t5)\n"); //null terminate.
		output.append("sw $t6, 4($fp)\n"); //save the data to the stack.

		return output.toString();
	    case CONCAT:
		//Label firstLoop = new Label();
		//Label secondLoop = new Label();
		
		repeatLoop = new Label();
		doneCounting = new Label();
		


		output.append("lw $t0, 4($fp) # Suck in the String1 address.\n");
		output.append("lw $t1, 8($fp) # Suck in the String2 address.\n");
		
		output.append("add $t9, $t1, $zero\n"); //save the second string address for the moment.
		output.append("add $t8, $t0, $zero\n");

	    
		//first figure out the size...
		for(int i = 0; i < 2; i++)
		    {
		    repeatLoop = new Label();
		    doneCounting = new Label();
		    
		    subCode = "beqz $t6, " + doneCounting + "\n";
		    subCode += "addi $t2, $t2, 1\n"; //increment the count.

		    output.append("li $t1, 0\n");
		    output.append("li $t2, 0\n");
		
		    //begin the loop.
		    output.append(repeatLoop + ": #Top of string counting loop. \n");
		    //output.append("lw $t5, $t1($t0)\n");
		    output.append("add $s0, $t1, $t0\n");
		    output.append("lw $t5, 0($s0)\n");
		
		
		    output.append("srl $t6, $t5, 24\n");
		    output.append("andi $t6, $t6, 0xff\n");
		    //output.append("andi $t6, $t5, 0xff000000\n");
		    output.append(subCode);
		    output.append("srl $t6, $t5, 16\n");
		    output.append("andi $t6, $t6, 0xff\n");
		    //output.append("andi $t6, $t5, 0xff0000\n");
		    output.append(subCode);
		    output.append("srl $t6, $t5, 8\n");
		    output.append("andi $t6, $t6, 0xff\n");
		    //output.append("andi $t6, $t5, 0xff00\n");
		    output.append(subCode);
		    output.append("andi $t6, $t5, 0xff\n");
		    output.append(subCode);
		    
		    output.append("addi $t1, $t1, 4\n");
		    output.append("b " + repeatLoop + " #count next word of stiring bytes.\n");
		    
		    output.append(doneCounting + ":\n");

		    if(i == 0)
			{
			repeatLoop = new Label();
			doneCounting = new Label();
			output.append("add $t7, $t2, $zero #Move the count to $t7, save for later.\n");
			output.append("add $t0, $t9, $zero #Move the address of the next string down to $t0 and repeat.\n");
			}
		    }
	    
		output.append("add $t7, $t2, $zero #This is the total length of the two strings.\n");
	    
		/*
		    $t7 contains the total size, $t8 and $t9
		    still contain the original pointers to
		    the original strings.
		*/
	    
		output.append("addi $a0, $t7, 1 #Need room for the ending null.\n"); //we need room for the ending null.
		output.append("li $v0, 9 #Allocate the new array\n"); // 9 == sbrk
		output.append("syscall\n");
		
		output.append("add $t0, $v0, $zero #Move address of new string to $t0 and $t7.\n"); 
		output.append("add $t7, $t0, $zero\n"); //starting address of new string.
	    
		output.append("add $t1, $t8, $zero #Start with our first string.\n");
	    
		Label branchRedo = new Label();
		Label branchNext = new Label();
	    
		output.append(branchRedo + ": #Top of first string copying loop.\n");
		output.append("lb $t3, 0($t1)\n");
		output.append("beqz $t3, " + branchNext + "\n");
		output.append("sb $t3, 0($t0)\n");
		
		output.append("addi $t1, $t1, 1\n");
		output.append("addi $t0, $t0, 1\n");
		output.append("b " + branchRedo + "\n");
		output.append(branchNext + ":\n");
		
		output.append("add $t1, $t9, $zero #Now time for the second string.\n");
		
		branchRedo = new Label();
		branchNext = new Label();
	    
		output.append(branchRedo + ": #Top of the second string copying loop.\n");
		output.append("lb $t3, 0($t1)\n");
		output.append("beqz $t3, " + branchNext + "\n");
		output.append("sb $t3, 0($t0)\n");
		
		output.append("addi $t1, $t1, 1\n");
		output.append("addi $t0, $t0, 1\n");
		output.append("b " + branchRedo + "\n");
		output.append(branchNext + ":\n");
		
		output.append("li $t3, 0\n");
		output.append("sb $t3, 0($t0) #Null terminate.\n");
		
		output.append("sw $t7, 4($fp)\n"); //save the data to the stack.
	    
		return output.toString();
	    case NOT:
		output.append("lw $t0, 4($fp) # Suck in the int to be notted.\n");
		output.append("seq $t1, $t0, $zero\n");
		output.append("sw $t1, 4($fp)\n"); //save the data to the stack.
		return output.toString();
	    case EXIT:
		output.append("li $v0, 10     # code for exit.\n");
		output.append("syscall\n");
		return output.toString();
	    default:
		return "# not handled";
	    }
	}
}
