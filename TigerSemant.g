header {
  import Semant.Type;
  import Semant.Environment;
  import Semant.LineAST;
  import Semant.Entry;
  import Semant.VarEntry;
  import Semant.FunEntry;
}

class TigerSemant extends TreeParser;

options {
  importVocab = Tiger;
  ASTLabelType = "Semant.LineAST";
}

{
  Environment env = new Environment();

  void semantError(LineAST a, java.lang.String s) {
    System.err.println(a.getLine() + ":" + s);
    System.exit(1);
  }
}

lvalue returns [Type t]
    { Type a, b; t = env.getVoidType(); }
  : i:ID
    { /* Verify ID is a variable in the current scope, return its type */
      Entry e = (Entry) env.vars.get(i.getText());
      if ( e == null )
	semantError(i, "Undefined identifier " + i.getText());
      if ( !(e instanceof VarEntry) )
	semantError(i, i.getText() + " is not a variable");
      VarEntry v = (VarEntry) e;
      t = v.ty;
    }
  | #( FIELD a=lvalue ID )
    { /* Verify lvalue is of record type with ID as a field */ }
  | #( SUBSCRIPT a=lvalue b=expr)
    { /* Verify lvalue is an array type and expr is an int */ }
  ;

expr returns [Type t]
    { Type a, b, c; t = env.getVoidType();}
  : "nil" { t = env.getNilType(); }
  | t=lvalue
  | STRING { t = env.getStringType(); }
  | NUMBER { t = env.getIntType(); }
  | #( NEG a=expr
       { /* Verify expr is an int */
      	   if ( !(a instanceof Semant.INT))
	        semantError(#expr, "Operand of unary minus must be integer");
	   t = env.getIntType();
       }
     )
  | #( BINOP a=expr b=expr
       { /* Verify expr's types match, more picky for non-equality. */
	 String op = #expr.getText();
         if ( op.equals("+") ||
	      op.equals("-") ||
	      op.equals("*") ||
	      op.equals("/") ) {
	     if (!(a instanceof Semant.INT) ||
		 !(b instanceof Semant.INT))
		 semantError(#expr, "operands of " +op+ " must be integer");
	     t = a;
	 } else {
	     semantError(#expr, "other operators unimplemented");
	     t = env.getVoidType();
	 }
       }
     )
  | #( ASSIGN a=lvalue b=expr
       { /* Verify the lvalue's type matches the expr's type */
         semantError(#expr, "assignment unimplemented");
	 t = env.getVoidType();
       }
     )
  | #( CALL ID (a=expr)*
       { /* Verify ID is a function and that the number and type of its
            actual arguments match the formal ones */
         semantError(#expr, "function call unimplemented");
	 t = env.getVoidType();
       }
     )
  | #( SEQ { t = env.getVoidType(); } (t=expr)*
       { /* Return the type of the last expression or nil */ }
     )
  | #( RECORD ID (#(FIELD ID a=expr))*
       { /* Verify ID is a record type and that the listed fields match those
            of the record type */
         semantError(#expr, "new record unimplemented");
	 t = env.getVoidType();
       }
     )
  | #( NEWARRAY ID a=expr a=expr
       { /* Verify ID is an array type, the first expr is an int, and the
            second matches the type of the array */
         semantError(#expr, "new array unimplemented");
	 t = env.getVoidType();
       }
     )
  | #( "if" a=expr b=expr (c=expr)?
       { /* Verify the first expr is an int, that the second, if alone, is   
            nothing, and the second and third match if there's a third */
         semantError(#expr, "if unimplemented");
	 t = env.getVoidType();
       }
     )
  | #( "while" a=expr b=expr
       { /* Verify the first expr is an int and that the second is nothing */
         semantError(#expr, "while unimplemented");
	 t = env.getVoidType();
       }
     )
  | #( "for" ID a=expr b=expr c=expr
       { /* Verify the first and second expressions are ints, define the ID as
            an int for the third, and verify its type is empty in a new scope.
         */
         semantError(#expr, "for unimplemented");
	 t = env.getVoidType();
       }
     )
  | "break" { t = env.getVoidType(); }
  | #( "let"
       { env.enterScope(); }
       #(DECLS (#(DECLS (decl)+ ))* )
       a=expr
       {
         env.leaveScope();
         t = a;
       }
     )
  ;

decl
    { Type a, b; }
  : #( "type" ID a=type
       { /* Add the given type to the current scope */
         semantError(#decl, "type unimplemented");
       }
     )
  | #( "var" i:ID (a=type | "nil" { a = null; } ) b=expr
       { /* Verify the type of the expression matches the given type
            if non-nil, and add the var declaration to the current scope */
         env.vars.put(i.getText(), new VarEntry(b));
       }
     )
  | #( "function" ID fields (a=type | "nil" { a = null; } ) b=expr
       { /* Verify the arguments are actually types, enter the
            function in the current scope, start a new scope, add the formal
            parameters, check the body, and leave the scope */
         semantError(#decl, "function unimplemented");
       }
     )
  ;

type returns [Type t]
    { t = env.getVoidType(); }
  : ID
  | fields
  | #( "array" ID )
  ;

fields : #( FIELDS ( #(FIELD ID ID) )* ) ;

