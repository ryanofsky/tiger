package Interp;

public class Label extends Statement {
    String name;

    static int count = 0;

    /// Create a new local label
    public Label() { name = "Label" + Integer.toString(count++, 10); }

    /// Create a new named label
    public Label(String n) { name = n; }

    public String string() {
	return name + ":";
    }

    public String value() { return name; }

    /// Do nothing; return the next statement
    public Statement execute(Environment e) { return next; }

    public String mips() { return name + ":"; }
}
