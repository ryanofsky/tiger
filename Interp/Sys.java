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
}
