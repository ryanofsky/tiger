package Interp;

/// Stacked activation record: static, dynamic links, return addresss, and data
public class Activation {

    /// Lexically scoped parent
    public Activation staticLink;

    /// Next activation record on the stack
    public Activation dynamicLink;

    public Statement returnAddress;    

    java.util.Vector contents;

    /// Positive arguments refer to this record; negative refer to the last
    TigerObj get(int i) {       
	if ( i >= 0 ) return (TigerObj)contents.elementAt(i);
	else
	    return (TigerObj)dynamicLink.contents.elementAt(dynamicLink.contents.size()+i);
    }

    /// Positive arguments refer to this record; negative refer to the last
    void set(int i, TigerObj o) {
	if ( i >= 0 ) contents.setElementAt(o, i);
	else dynamicLink.contents.setElementAt(o, dynamicLink.contents.size()+i );
    }

    /// Adjust the stack pointer to add (positive) or remove (negative) items
    void adjust(int i) {
	contents.setSize(contents.size() + i);
    }

    Activation(Activation sl, Activation dl, Statement adr) {
	staticLink = sl;
	dynamicLink = dl;
	returnAddress = adr;
	contents = new java.util.Vector();
    }
}


