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

    TigerObj toReturn = null;

	switch (number) {
	case PRINT:
	case PRINTI: 
	    System.out.print( e.stack.get(-1).string() );
	    break;
	case FLUSH:
	    System.out.flush();
	    break;
	case GETCHAR:
	    try
		{
		char[] theChar = new char[1];
		theChar[0] = (char) System.in.read();
		toReturn = new STRING(new String(theChar));
		e.stack.set(-1, toReturn);
		}
	    catch(Exception l)
		{e.stack.set(-1, new STRING(-1 + ""));}
	    break;
	case ORD:
	    String temp1 = e.stack.get(-2).string();
	    char blah = temp1.charAt(0);
	    toReturn = new INT(blah);
	    e.stack.set(-1, toReturn);
	    break;
	case CHR:
	    char[] temp = new char[1];
	    temp[0] = (char) Integer.parseInt(e.stack.get(-2).string());
	    String goingBack = new String(temp);
	    toReturn = new STRING(goingBack);
	    e.stack.set(-1, toReturn);
	    break;
	case SIZE:
	    String sizer = e.stack.get(-2).string();
	    toReturn = new INT(sizer.length());
	    e.stack.set(-1, toReturn);
	    break;
	case SUBSTRING:
	    String theString = e.stack.get(-2).string();
	    int i1 = Integer.parseInt(e.stack.get(-3).string());
	    int i2 = Integer.parseInt(e.stack.get(-4).string());
	
	    toReturn = new STRING(theString.substring(i1, i2 + 1));
	    //toReturn = new STRING("blah");
	    e.stack.set(-1, toReturn);
	    break;
	case CONCAT:
	    String input1 = e.stack.get(-2).string();
	    String input2 = e.stack.get(-3).string();
	
	    toReturn = new STRING(input1 + input2);
	    e.stack.set(-1, toReturn);
	    break;
	case NOT:
	    int input = Integer.parseInt(e.stack.get(-2).string());
	    int output = 0;
	    
	    if(input == 0)
		{output = 1;}
	    
	    toReturn = new INT(output);
	    e.stack.set(-1, toReturn);
	    break;
	case EXIT:
	    System.exit(0);
	    break;
	}
       
	return next;
    }
}
