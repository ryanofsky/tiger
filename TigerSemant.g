header {
  import Semant.Type;
  import Semant.Environment;
  import Semant.LineAST;
  import Semant.Entry;
  import Semant.VarEntry;
  import Semant.FunEntry;

    import java.util.Vector;

  import Semant.*;
}

class TigerSemant extends TreeParser;

options {
  importVocab = Tiger;
  ASTLabelType = "Semant.LineAST";
}

{
  Environment env = new Environment();

    boolean isReadOnly = false;

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
	
    if(env.vars.get(i.getText() + " isLocked") != null)
	{isReadOnly = true;}
    else
	{isReadOnly = false;}

      VarEntry v = (VarEntry) e;
      t = v.ty;
    }
  | #( FIELD a=lvalue m:ID )
    { /* Verify lvalue is of record type with ID as a field */
    
    a = a.actual();
    
    if(!(a.actual() instanceof RECORD))
        {semantError(#lvalue, #lvalue.getText() + " is not a record.");}

    RECORD d = (RECORD) a;

    String identifierName = m.getText();

    while(!d.fieldName.equals(identifierName))
        {
        d = d.tail;

        if(d == null)
            {
            semantError(#lvalue, #lvalue.getText() + " is not a field in this record.");
            break;
            }
        }

    isReadOnly = false;
    t = d.fieldType;
    }
  | #( SUBSCRIPT a=lvalue b=expr)
    { /* Verify lvalue is an array type and expr is an int */
    if(!(a.actual() instanceof ARRAY))
        {semantError(#lvalue, "This is not an array: " + a);}

    if(!(b.actual() instanceof INT))
        {semantError(#lvalue, "Array indices must be integers");}

    isReadOnly = false;
    t = ((ARRAY) a.actual()).element;
    }
  ;

expr returns [Type t]
    { Type a, b, c = null; t = env.getVoidType();}
  : "nil" { t = env.getNilType(); }
  | t=lvalue
  | STRING { t = env.getStringType(); }
  | NUMBER { t = env.getIntType(); }
  | #( NEG a=expr
       { /* Verify expr is an int */
           if ( !(a.actual() instanceof Semant.INT))
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
              op.equals("/") ||
              op.equals("|") ||
              op.equals("&")              
              ) {
             if (!(a.actual() instanceof Semant.INT) ||
                 !(b.actual() instanceof Semant.INT))
                 semantError(#expr, "operands of " + op + " must be integer");
             t = a;
         } else { // op is one of: = > < <> >= <=
            if(!b.coerceTo(a) && !a.coerceTo(b))
                {semantError(#expr, "operands of " + op + " must be of the same type.");}

            if(a.actual() instanceof VOID)
                {semantError(#expr, "operands of " + op + " cannot be applied to void types.");}

            t = env.getIntType();
         }
       }
     )
  | #( ASSIGN {isReadOnly = false;} a=lvalue 
	{
	if(isReadOnly)
	    {semantError(#expr, "You cannot assign to a read only variable.");}
	}
    b=expr
       { /* Verify the lvalue's type matches the expr's type */

        if(!b.coerceTo(a))
            {semantError(#expr, "Cannot assign a value of one type to a variable of a different type.");}

        t = env.getVoidType();
       }
     )
  | #( CALL z:ID
        {

        /*
            must fix to allow for mutually recursive functions.
        */

        if(env.vars.get(z.getText()) == null)
            {semantError(z, "undefined function " + z.getText());}

        FunEntry theFunction = (FunEntry) env.vars.get(z.getText());
        RECORD jello = theFunction.formals;
        Type result = theFunction.result;
        int argCount = 0;

        }
    (a=expr {

        if(jello == null)
            {semantError(z, "Too many arguments for function '" + z.getText() + "' (" + argCount + " expected)");}

        if(!a.coerceTo(jello.fieldType))
            {semantError(z, "Argument " + (argCount + 1) + " for function '" + z.getText() + "' has the wrong type.");}

        jello = jello.tail;
        ++argCount;
        })*
       { 

        if(jello != null)
            {semantError(z, "Too few arguments specified for function '" + z.getText() + "'");}

         t = result;
       }
     )
  | #( SEQ { t = env.getVoidType(); } (t=expr)*
       { /* Return the type of the last expression or nil */ }
    )
  | #( RECORD fuckoff:ID 
    {
    Type recType = (Type) env.types.get(fuckoff.getText());
    
    if (recType == null)
	{ semantError(#expr, "Undefined type: " + fuckoff.getText()); }
    
    if(!(recType.actual() instanceof RECORD))
	{semantError(#expr, fuckoff.getText() + " is not a valid name for a record.");}
    
    RECORD ourRec = (RECORD) recType.actual();
    } 
    (#(FIELD g:ID a=expr)
	{
	if(ourRec == null)
	    {semantError(#expr, "You have assigned to more fields than this record has in its definition.");}
	
	if(!ourRec.fieldName.equals(g.getText()))
	    {semantError(#expr, "The field names given in the initialization of this record don't match the field types in its declaration.");}
    
	if(!a.coerceTo(ourRec.fieldType))
	    {semantError(#expr, "The type of the value assigned to " + ourRec.fieldName + " does not match the declared type of the field.");}
    
	ourRec = ourRec.tail;
	}
    )*
       { /* Verify ID is a record type and that the listed fields match those
            of the record type */
	
	if(ourRec != null)
	    {semantError(#expr, "You must assign to all of the record's fields.");} 
	    
	t = recType;
       }
     )
  | #( NEWARRAY anddie:ID a=expr b=expr
       { /* Verify ID is an array type, the first expr is an int, and the
            second matches the type of the array */

        Type selected = (Type) env.types.get(anddie.getText());
        selected = selected.actual();

        if(!(selected instanceof ARRAY))
            {semantError(anddie, anddie.getText() + " is not a valid array type.");}

        ARRAY canidate = (ARRAY) selected;

        if(!(a.actual() instanceof INT))
            {semantError(anddie, "Array sizes must be integers.");}

        if(!b.coerceTo(canidate.element))
            {semantError(anddie, "Cannot initialize an array to a value of a type other than the type of the array.");}

         t = canidate;
       }
     )
  | #( "if" a=expr b=expr (c=expr)?
       { /* Verify the first expr is an int, that the second, if alone, is
            nothing, and the second and third match if there's a third */

        if (!(a.actual() instanceof INT))
            {semantError(#expr, "The predicate of an if statement must be of integer type.");}

        if (c == null && !(b.actual() instanceof VOID))
            {semantError(#expr, "The then block of an if statment cannot return a value if there is no else block.");}
        else if (c != null)
            {
            if (c.coerceTo(b))
                {t = b.actual();}
            else if (b.coerceTo(c))
                {t = c.actual();}
            else
                {semantError(#expr, "The types of the then and else blocks of an if statement must match.");}

            }

        t = b.actual();

        c = null;
       }
     )
  | #( "while" a=expr {env.enterScope(); env.vars.put("break viable", "true"); } b=expr
       { /* Verify the first expr is an int and that the second is nothing */

        if(!(a.actual() instanceof INT))
            {semantError(#expr, "The predicate of a while statement must be of integer type.");}

       if(!(b.actual() instanceof VOID))
            {semantError(#expr, "Foolishly, Tiger does not allow while statements to have a type. May I suggest a do-nothing assignment within the loop to force the value of the body of the while loop to be void?");}


	 
	 //added to allow break checking. 
	 env.leaveScope();
	t = env.getVoidType();
       }
     )
  | #( "for" m:ID a=expr b=expr 
	{ 
	env.enterScope(); 
	env.vars.put(m.getText(), new VarEntry(env.getIntType())); 
	env.vars.put("break viable", "true");
	env.vars.put(m.getText() + " isLocked", "true");
	} c=expr
       { /* Verify the first and second expressions are ints, define the ID as
            an int for the third, and verify its type is empty in a new scope.
         */

         if(!(a.actual() instanceof INT))
            {semantError(m, "The starting value of " + m.getText() + " must be an integer.");}

         if(!(b.actual() instanceof INT))
            {semantError(m, "The ending value of " + m.getText() + " must be an integer.");}

         env.leaveScope();
         t = env.getVoidType();
       }
     )
  | "break" { 
    String breakable = (String) env.vars.get("break viable");
    
    if(breakable == null)
	{semantError(#expr, "Break may only be used from within a while or for loop.");}
  
  t = env.getVoidType();
  }
  | #( "let"
       { env.enterScope(); }
       #(DECLS
       ( 
        
         #(innerD:DECLS 
             {  AST ok = innerD.getFirstChild();}
             (decl)+ 
             { 
		Vector names = new Vector();
	     
                while(ok != null)
                    {
                    String name = decl2(ok);
		    
		    if(name != null)
			{names.add(name);}
		    
                    ok = ok.getNextSibling();
                    }
		
		for(int google = 0; google < names.size(); google++)
		    {
		    String currentName = (String) names.get(google);
		    
		    Type checkerType = (Type) env.types.get(currentName);
		    
		    if(checkerType instanceof NAME)
			{
			NAME nameForm = (NAME) checkerType;
			NAME next = nameForm;
			
			while(next.binding instanceof NAME)
			    {
			    if(next.binding == nameForm)
				{
				semantError(#expr, currentName + " is not a real type (merely an alias to an alias...., you get the point).");
				}
	
			    next = (NAME) next.binding;
			    //in while.
			    }
			//in if.
			}
		    //in for.
		    }
             //outside of all loops.
	     }
         ))*
       
       )
       a=expr
       {
         env.leaveScope();
         t = a;
       }
     )
  ;

decl
    { Type a, b;
    a = null;
    }
  : #( "type" y:ID
       { /* Add the given type to the current scope */
        String text = y.getText();
        NAME alias = new NAME(text);  
        env.types.put(text, alias);
       }
     )
  | #( "var" i:ID (a=type | "nil") b=expr
       { /* Verify the type of the expression matches the given type
            if non-nil, and add the var declaration to the current scope */

        if(a != null && !b.coerceTo(a))
            {semantError(i, "You cannot place a value of one type in a variable of an incompatible type.");}

        env.vars.put(i.getText(), new VarEntry(b));
       }
     )
  | #( "function" n:ID {RECORD l;} l=fields (a=type | "nil" { a = null; } )
          {
          if(a == null)
              {a = env.getVoidType();}
          FunEntry additionalFunction = new FunEntry(l, a);
          env.vars.put(n.getText(), additionalFunction);
          }
     )
  ;


decl2 returns[String s = null;]
    { Type a, b;
    a = null;
    }
  : #( "type" y:ID a=type
       { /* Add the given type to the current scope */
       NAME alias = (NAME) env.types.get(y.getText());
       alias.bind(a);
       s = y.getText();
       }
     )
  | "var"
  | #( "function" n:ID FIELDS .
       { 
         /* Verify the arguments are actually types, enter the
            function in the current scope, start a new scope, add the formal
            parameters, check the body, and leave the scope */

        FunEntry additionalFunction = (FunEntry)env.vars.get(n.getText());
        RECORD l = additionalFunction.formals;
        env.enterScope();

        while(l != null)
            {
            env.vars.put(l.fieldName, new VarEntry(l.fieldType));
            l = l.tail;
            }
       }
    b=expr 
        {
        env.leaveScope();
	
	if(!b.coerceTo(additionalFunction.result))
	    {semantError(#decl2, "The return type of " + n.getText() + " must match the declared return type of this function.");}
        }
    )
  ;


type returns [Type t]
    {
        Type q;
        t = env.getVoidType();
    }
  : k:ID
    {
    t = (Type) env.types.get(k.getText());
    }
  | q = fields
    {
    t = q;
    }
  | #( "array" p:ID
    {
    Type arrayType = (Type) env.types.get(p.getText());

    if(arrayType == null)
        {semantError(p, "The type of the elements of this array is not valid.");}

    t = new ARRAY(arrayType);
    }
    )
  ;



fields returns [RECORD rec = null;]: #( FIELDS
    {
    RECORD current = new RECORD("", null, null);
    rec = current;
    RECORD last = null;
    }
( #(FIELD m:ID u:ID
    {
    current.fieldName = m.getText();
    current.fieldType = (Type) env.types.get(u.getText());
    current.tail = new RECORD("", null, null);
    last = current;
    current = current.tail;
    } ) )*

    {
    if(last == null)
        {rec = null;}
    else
        {last.tail = null;}
    }

) ;

