package Semant;

import java.lang.String;

/**
 * Hashtable-based symbol table for a single scope.
 * Has a link to its parent scope: searches check there, too
 */
class Scope {

    Scope parent;
    java.util.Hashtable dict = new java.util.Hashtable();

    Scope() { parent = null; }
    Scope(Scope p) { parent = p; }

    public Object get(String key) {
	if ( dict.containsKey(key))
	    return dict.get(key);
	else if (parent != null)
	    return parent.get(key);
	else return null;
    }

    public void put(String key, Object entry) {
	dict.put(key,entry);
    }
}

/**
 * Symbol table with the notion of a scope.
 */
public class Table {

    private Scope top;

    public Table() { top = new Scope(); }

    /**
     * Gets the object associated with the specified symbol in the Table.
     */
    public Object get(String key) {
	return top == null ? null : top.get(key);
    }

    /**
     * Puts the specified value into the Table, bound to the specified symbol.
     */
    public void put(String key, Object value) {
	if (top != null) top.put(key, value);
    }

    /**
     * Push a scope on the top of the stack
     */
    public void enterScope() {
	top = new Scope(top);
    }

    /** 
     * Remove the scope at the top of the stack, forgetting its definitions.
     */
    public void leaveScope() {
	if ( top != null ) top = top.parent;
    } 
}


