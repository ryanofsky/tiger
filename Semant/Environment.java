package Semant;

import antlr.collections.AST;
//import TigerTokenTypes;
import java.lang.String;

/// Helper class for creating standard library functions
class Builtin {
    RECORD args = null;
    String name;
    Type returns;

    Builtin(String n) { name = n; }
    Builtin returns(Type r) { returns = r; return this;}
    Builtin arg(String n, Type t) {
	args = new RECORD(n, t, args); return this; 
    }
    void enter(Table t) { t.put( name, new FunEntry( args, returns )); }
}

public class Environment {

    /// Symbol table of Entries for functions and variables
    public Table vars = new Table();

    /// Symbol table of Types
    public Table types = new Table();

    /// Built-in int type
    INT intType;
    public INT getIntType() { return intType; }

    /// Built-in void type (returns nothing)
    VOID voidType;
    public VOID getVoidType() { return voidType; }

    /// Built-in nil type (type of nil, matches all records)
    NIL nilType;
    public NIL getNilType() { return nilType; }

    // Built-in string type
    STRING stringType;
    public STRING getStringType() { return stringType; }

    public Environment() {

	// Initialize built-in types

	intType = new INT();
	types.put("int", intType);
	stringType = new STRING();
	types.put("string", stringType);
	voidType = new VOID(); // void type is not in the symbol table
	nilType = new NIL(); // nil type is not in the symbol table

	/// Standard library functions.  Arguments listed in reverse order.

	new Builtin("print").arg("s", stringType).returns(voidType)
	    .enter(vars);
	new Builtin("printi").arg("i", intType).returns(voidType)
	    .enter(vars);
	new Builtin("flush").returns(voidType).enter(vars);
	new Builtin("getchar").returns(stringType).enter(vars);
	new Builtin("ord").arg("s", stringType).returns(intType).enter(vars);
	new Builtin("chr").arg("i", intType).returns(stringType).enter(vars);
	new Builtin("size").arg("s", stringType).returns(intType).enter(vars);
	new Builtin("substring").arg("n", intType).arg("first", intType)
	    .arg("s", stringType).returns(stringType).enter(vars);
	new Builtin("concat").arg("s2", stringType).arg("s1", stringType)
	    .returns(stringType).enter(vars);
	new Builtin("not").arg("i", intType).returns(intType).enter(vars);
	new Builtin("exit").arg("i", intType).returns(voidType).enter(vars);
    }

    /// Call when entering a scope: marks a place until a matching leaveScope
    public void enterScope() { vars.enterScope(); types.enterScope(); }

    /// Forgets all declarations made since the matching enterScope
    public void leaveScope() { vars.leaveScope(); types.leaveScope(); }    
}
