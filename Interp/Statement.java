package Interp;

public abstract class Statement {
    public Statement next = null;
    /// Return a textual representation of this statement
    public String string() { return "<unknown statement>"; }

    /// Execute this statement and return the next statement to execute, if any
    public Statement execute(Environment e) throws InterpException {
	return null;
    }

    /// Append a statement to the list starting at this one
    public Statement append(Statement s) {
	Statement n = this;
	while ( n.next != null ) n = n.next;
	n.next = s;
	return s;
    }

    /// Insert a statement after this one
    public Statement insert(Statement s) {
	s.append(next);
	next = s;
	return s;
    }

    public void printAll() {
	for ( Statement s = this ; s != null ; s = s.next )
	    System.out.println( s.string() );
    }

    public void executeAll(boolean trace) {
	Environment e = new Environment();
	try {
	    for ( Statement s = this ; s != null ; s = s.execute(e) ) {
		// Print statements as they are executed
		if (trace) System.out.println( s.string() );
	    }
	} catch (InterpException ex) {
	    System.err.println(ex);
	    System.exit(1);
	}
    }

    /// Return text for MIPS instructions that implement this statement
    public String mips() { return "# Unknown statement " + string(); }

    public void printMips() {
	for ( Statement s = this ; s != null ; s = s.next ) {
	    System.out.println("#" + s.string());
	    System.out.println(s.mips());
	}
    }

}
