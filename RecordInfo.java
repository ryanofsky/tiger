import Interp.Operand;
import Interp.FrameRel;
import Interp.StackLinks;
import Interp.Statement;
import Interp.Label;
import Interp.Ent;
import Interp.Psh;
import java.util.Vector;
import Interp.Psh;
import java.util.Vector;

/// Maintains information about what is stored in an activation record
class RecordInfo {

    /// The activation record for this record's lexical parent
    RecordInfo parent;

    /// The statement for the function being built: add code here
    public Statement func;

    /// Append a statement to the function being built for this record
    public Statement append(Statement s) { return func.append(s); }

    Vector functions = null;

    public RecordInfo(String name) {
	parent = null;
	func = new Label(name);
	func.append(new Ent());
	functions = new Vector();
    }

    public RecordInfo(String name, RecordInfo p) {
	parent = p;
	func = new Label(name);
	func.append(new Ent());
    }



    /*
     * Fields and methods that manage where data is stored in this activation
     * record.
     */
     
    public Vector functionArgs = new Vector();

    /// Offset for next available stack position
    int tos = 0; 
    
    /// Highest number of stack objects seen so far
    public int max = 0;
    
    /// Return the size of this activation record (maximum number used)
    public int size() { return max; }

    /// Stack of top-of-stack values for enter/leave
    java.util.Stack markStack = new java.util.Stack();

    /// Save the current tos so a later release() method can restore it
    public void mark() { markStack.push(new Integer(tos)); }

    /// Restore the tos to that of the most recent mark() operation
    public void release() {
	int lasttos = tos;
	tos = ((Integer)(markStack.pop())).intValue();
	//if (lasttos > tos) func.append(new Psh(tos-lasttos));
    }

    /// Return an operand pointing the next available space on the stack
    public Operand newTmp() {
	FrameRel op = new FrameRel(tos);
	//func.append(new Psh(1));
	tos++;
	if ( tos > max ) max = tos;
	return op;
    }
    
    Vector endTmps = new Vector();

    // return an operand that is the end of the stack
    // (used for function arguments and return values)
    // the operands will be pointed to the right spots
    // when the stack is allocated
    public FrameRel newEndTmp()
    {
      FrameRel op = (FrameRel) newTmp();
      endTmps.add(op);
      return op;
    }
    
    public void newEnd()
    {
      endTmps.add(new Integer(max));
    }

    public void allocateStack()
    {
      for(int i = 0; i < functionArgs.size(); ++i)
        ((FrameRel)functionArgs.get(i)).offset += max;
	
      //func.insert(new Psh(max));
      
      Statement temp = func.next.next;
      func.next.next = new Psh(max);
      func.next.next.next = temp;  
      
      int oldMax = 0;
      
      for(int i = endTmps.size() - 1; i >= 0; --i)
      {
        Object o = endTmps.get(i);
        if (o instanceof Integer)
        {
          oldMax = ((Integer)o).intValue();
        }
        else if (o instanceof FrameRel)
        {
          FrameRel f = (FrameRel)o;
          f.offset += max - oldMax;
        }
        else // never happens
          throw new Error("Unrecognized object in endTmps vector");
        
      }
    }

    /*
     * Fields and methods that manage symbol tables to track variables'
     * position in this activation record.
     */

    // Represents scopes for variables within this activation record
    public class Scope {
	Scope parent;
	java.util.Hashtable dict = new java.util.Hashtable();

	public Scope() { parent = null; }
	public Scope(Scope p) { parent = p; }

	/// Locate an identifier in this or an enclosing scope
	public Object get(String key) {
	    if ( dict.containsKey(key))
		return dict.get(key);
	    else if (parent != null)
		return parent.get(key);
	    else return null;
	}

	/// Enter an identifier in this scope
	public void put(String key, Object entry) { dict.put(key,entry); }
    }

    /// Topmost scope in this activation record
    public Scope topScope = new Scope();

    /// Enter a new scope
    public void enterScope() { topScope = new Scope(topScope); }

    /// Leave the topmost scope, forgetting its bindings
    public void leaveScope() { topScope = topScope.parent; }

    /// Add storage for a variable to this scope
    public Operand newVar(String n) {
	int varOffset = tos;
	topScope.put(n, new Integer(varOffset));
	return newTmp();
    }

    /** Return an operand that accesses the given variable while this
	activation record is active.  This may follow static links, so
	it's important to use the result immediately. */
    public Operand findVar(String n) {
	int depth = 0;
	int offset = 0;
	RecordInfo ri = this;
	while (ri != null) {
	    Object o = ri.topScope.get(n);
	    if (o != null) {
		// Located the variable
		offset = ((Integer)(o)).intValue();
		break;
	    }
	    ++depth; // Didn't find it here, so
	    ri = ri.parent; // look in the next outermost activation record
	}

	if ( ri == null ) {
	    // Should never happen: failure means either static semantics
	    // weren't checked correctly or that the contents of the
	    // scopes weren't set up correctly.
	    // throw new Exception("variable " + n + " not found");
	}
	if ( depth == 0 ) return new FrameRel(offset);
	return new StackLinks(offset, depth);
    }

    /// Enter the definition for a function in the symbol table
    public void enterFunc(String n, Statement s)
    {
      topScope.put(n, s);
      RecordInfo ri = this;
      while(ri.functions == null)
        ri = ri.parent;
      ri.functions.add(s);
    }

    public void printAll()
    {
      for(int i = 0; i < functions.size(); ++i)
      {
        Label f = (Label)functions.get(i);
        f.printAll();
      }
      func.printAll(); 
    }

    /// Locate a function in the symbol table by name
    public Statement getFunc(String n) {
	for ( RecordInfo ri = this ; ri != null ; ri = ri.parent ) {
	    Object o = ri.topScope.get(n);
	    if ( o != null ) {
		// Located the Statement for the function, return it
		// A type error here means an erroneous program got through;
		// A function and a variable with the same name should never
		// be visible in the same scope.
		return (Statement)o;
	    }
	}
	// Should never happen: indicates a function was not correctly entered
	// in the symbol tables
	return null;
    }
    
    
    public Object getThing(String input)
	{return topScope.get(input);}
	
    public void putThing(String input, Object thing)
	{topScope.put(input, thing);}
}
