package Interp;

public class StringConstant extends Operand {
    String v;
    public StringConstant(String s) { v = s; }

    public TigerObj get(Environment e) { return new STRING(v); }

    public String string() { return "\"" + escapedString() + "\""; }

    /// Number of string constants used
    static int count = 0;

    public String mipsGet(String reg) {
	String lab = "_st" + Integer.toString(count, 10);
	++count;
	return
	    "  .data\n" + // Switch to data segment for string constant
	    lab + ":\n" +
	    "  .asciiz \"" + escapedString() + "\"\n" +
	    "  .text\n" +
	    "  la " + reg + ", " + lab;
    }

    String escapedString() {
	StringBuffer sb = new StringBuffer();

	for ( int i = 0 ; i < v.length() ; i++ ) {
	    char c = v.charAt(i);
	    if ( c == '\n' ) {
		sb.append("\\n");
	    } else {
		sb.append(c);
	    }
	}
	return sb.toString();
    }
}
