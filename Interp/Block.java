package Interp;

public class Block extends Reference {
    TigerObj entries[];

    /// Constructor for records: fill with NILs; caller must fill in entries
    public Block(int n) {
        entries = new TigerObj[n];
        for ( int i = 0 ; i < n ; i++ ) entries[i] = new NIL();
    }

    /// Constructor for arrays: fill with copies of the object
    public Block(int n, TigerObj o) {
	entries = new TigerObj[n];
	for ( int i = 0 ; i < n ; i++ ) entries[i] = o.copy();
    }

    public TigerObj get(int i) throws NilAccessException { return entries[i]; }
    public void set(int i, TigerObj o) {
	entries[i] = o;
    }

    public String string() {
	String result;
	result = "[ ";
	for ( int i = 0 ; i < entries.length ; i++ )
	    result += entries[i].string() + " ";
	result += "]";
	return result;
    }
}
