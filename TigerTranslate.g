header {
  import Semant.Type;
  import Semant.Environment;
  import Semant.LineAST;
  import Semant.Entry;
  import Semant.VarEntry;
  import Semant.FunEntry;

  import java.util.Vector;

  import Interp.*;
  import Semant.*;
}

class TigerTranslate extends TreeParser;

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




lvalue [ RecordInfo r ] returns [ Pair output = null;]
    {
    Type t;
    Type a, b;
    Pair p;
    Operand o; 
    Operand lval = null; 
    }
  : i:ID 
    { 

    t = env.getVoidType(); 
    
      /* Verify ID is a variable in the current scope, return its type */
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
      
      output = new Pair(t, r.findVar(i.getText()));
    }
  | #( FIELD p=lvalue[r] m:ID )
    { /* Verify lvalue is of record type with ID as a field */
    
    a = (Type) p.left;
    a = a.actual();
    
    if(!(a.actual() instanceof RECORD))
        {semantError(#lvalue, #lvalue.getText() + " is not a record.");}

    RECORD d = (RECORD) a;

    String identifierName = m.getText();

    int counter = 0;
    
    while(!d.fieldName.equals(identifierName))
        {
	counter++;
        d = d.tail;

        if(d == null)
            {
            semantError(#lvalue, #lvalue.getText() + " is not a field in this record.");
            break;
            }
        }

    isReadOnly = false;
    t = d.fieldType;
    
    BlockRel br = new BlockRel((Operand) p.right, new IntConstant(counter));
    
    //here.
    output = new Pair(t, br);
    }
  | #( SUBSCRIPT p=lvalue[r] {Operand tmp = r.newTmp();} b=expr[tmp, r]
    { /* Verify lvalue is an array type and expr is an int */
    a = (Type) p.left;
    
    if(!(a.actual() instanceof ARRAY))
        {semantError(#lvalue, "This is not an array: " + a);}

    if(!(b.actual() instanceof Semant.INT))
        {semantError(#lvalue, "Array indices must be integers");}

    isReadOnly = false;
    t = ((ARRAY) a.actual()).element;
    
    BlockRel br = new BlockRel((Operand) p.right, tmp);
    
    output = new Pair(t, br);
    }
    );









expr [ Operand d, RecordInfo r ] returns [Type t] 
    {
    Type a, b, c = null; 
    t = env.getVoidType();
    Operand o;
    Pair p;
    }
  : "nil" 
    { 
    t = env.getNilType(); 
    r.append( new Mov(d, new NilConstant() ) );
    }
  | p=lvalue[r]
    {
    t = (Type) p.left;
    r.append( new Mov(d, (Operand) p.right));
    }
  | s:STRING 
    {
    r.append( new Mov(d, new StringConstant(s.getText()))); 
    t = env.getStringType(); 
    }
  | n:NUMBER 
    {
    r.append(new Mov(d, new IntConstant(Integer.parseInt(n.getText(),10))));
    t = env.getIntType(); 
    }
  | #( NEG a=expr[d, r]
       { /* Verify expr is an int */
           if ( !(a.actual() instanceof Semant.INT))
                semantError(#expr, "Operand of unary minus must be integer");
           t = env.getIntType();
       }
     )
     { 
     r.append( new Neg(d, d)); 
     }
  | #( BINOP a=expr[d,r] {r.mark(); Operand tmp = r.newTmp();} b=expr[tmp,r]
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
	 
	 
	// FIXME: Change this to use the right operator
	r.append( new Binop(Binop.ADD, d, d, tmp));
	r.release();
       }
     )
  | #( ASSIGN {isReadOnly = false;} p=lvalue[r]
	{
	if(isReadOnly)
	    {semantError(#expr, "You cannot assign to a read only variable.");}

	o = (Operand) p.right;
	a = (Type) p.left;
	}
    b=expr[o,r]
       { /* Verify the lvalue's type matches the expr's type */

        if(!b.coerceTo(a))
            {semantError(#expr, "Cannot assign a value of one type to a variable of a different type.");}

        t = env.getVoidType();
       }
     )
  | #( CALL z:ID
        {
        if(env.vars.get(z.getText()) == null)
            {semantError(z, "undefined function " + z.getText());}

        FunEntry theFunction = (FunEntry) env.vars.get(z.getText());
        RECORD jello = theFunction.formals;
        Type result = theFunction.result;
        int argCount = 0;

        }
    (a=expr[d,r] {

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

	/* 
	    Allocate space for each of the arguments, evaluate each, and
            call the function with a jsr.  Find the label with r.getFunc 
	*/




       }
     )
  | #( SEQ { t = env.getVoidType(); } (t=expr[d,r])*
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
    
    /* Create the new record with a rec statement */
    } 
    (#(FIELD g:ID {/* Store each expression with the proper offset */} a=expr[d,r])
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
  | #( NEWARRAY anddie:ID a=expr[d,r] b=expr[d,r]
       { 
        Type selected = (Type) env.types.get(anddie.getText());
        selected = selected.actual();

        if(!(selected instanceof ARRAY))
            {semantError(anddie, anddie.getText() + " is not a valid array type.");}

        ARRAY canidate = (ARRAY) selected;

        if(!(a.actual() instanceof Semant.INT))
            {semantError(anddie, "Array sizes must be integers.");}

        if(!b.coerceTo(canidate.element))
            {semantError(anddie, "Cannot initialize an array to a value of a type other than the type of the array.");}

         t = canidate;
	 
	 /* Create a new array with an arr statement */
       }
     )
  | #( "if" a=expr[d,r] b=expr[d,r] (c=expr[d,r])?
       { /* Verify the first expr is an int, that the second, if alone, is
            nothing, and the second and third match if there's a third */

        if (!(a.actual() instanceof Semant.INT))
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
	
	/* 
	    Evaluate the first expression, bz past the first
            expression's code, unconditional branch to the end,
            evalute the second expression, if any,
            then finally add the trailing label. 
	*/
	
       }
     )
  | #( "while" a=expr[d,r] {env.enterScope(); env.vars.put("break viable", "true"); } b=expr[d,r]
       {
        if(!(a.actual() instanceof Semant.INT))
            {semantError(#expr, "The predicate of a while statement must be of integer type.");}

       if(!(b.actual() instanceof VOID))
            {semantError(#expr, "Foolishly, Tiger does not allow while statements to have a type. May I suggest a do-nothing assignment within the loop to force the value of the body of the while loop to be void?");}

	 //added to allow break checking. 
	 env.leaveScope();
	t = env.getVoidType();
	
	/* 
	    Evaluate the first expression, bz to the end,
            evaluate the second expression, then branch back to
            the beginning. 
	*/
       }
     )
  | #( "for" m:ID a=expr[d,r] b=expr[d,r] 
	{ 
	env.enterScope(); 
	env.vars.put(m.getText(), new VarEntry(env.getIntType())); 
	env.vars.put("break viable", "true");
	env.vars.put(m.getText() + " isLocked", "true");
	} c=expr[d,r]
       { 
         if(!(a.actual() instanceof Semant.INT))
            {semantError(m, "The starting value of " + m.getText() + " must be an integer.");}

         if(!(b.actual() instanceof Semant.INT))
            {semantError(m, "The ending value of " + m.getText() + " must be an integer.");}

         env.leaveScope();
         t = env.getVoidType();
	 
	 /* 
	    Enter a new scope, create, and add code that initializes the
            index variable to the value of the second expression.
            Compare the index variable with the second expression and bnz to
            the end.  Generate code for the third expression, code that
            increments the index by one, then branch to the beginning. 
	*/
	 
	 
       }
     )
  | "break" { 
    String breakable = (String) env.vars.get("break viable");
    
    if(breakable == null)
	{semantError(#expr, "Break may only be used from within a while or for loop.");}
  
  t = env.getVoidType();
  
    /* 
	Unconditional branch to the innermost loop exit 
    */
  }
  | #( "let"
       { 
	env.enterScope(); 
	r.mark(); 
	r.enterScope();
       }
       #(DECLS
       ( 
        
         #(innerD:DECLS 
             {  AST ok = innerD.getFirstChild();}
             (decl[d,r])+ 
             { 
		Vector names = new Vector();
	     
                while(ok != null)
                    {
                    String name = decl2(ok,d,r);
		    
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
       a=expr[d,r]
       {
         env.leaveScope();
         t = a;
	 r.release(); 
	 r.leaveScope();
       }
     )
  ;

decl [ Operand d, RecordInfo r ]
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
  | #( "var" i:ID (a=type | "nil") b=expr[d,r]
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


decl2 [ Operand d, RecordInfo r ] returns [String s = null;]
    { 
    Type a, b;
    a = null;
    }
  : #( "type" y:ID a=type
       { /* Add the given type to the current scope */
       NAME alias = (NAME) env.types.get(y.getText());
       
       if(a == null)
	    {semantError(y, y.getText() + "Is being assigned an invalid type.");}
       
       alias.bind(a);
       s = y.getText();
       }
     )
  | #( "var"
       i:ID { Operand v = r.newVar(i.getText()); }
       (ID | "nil")
       a=expr[v,r]
     )
  | #( "function" n:ID FIELDS .
       { 
        FunEntry additionalFunction = (FunEntry)env.vars.get(n.getText());
        RECORD l = additionalFunction.formals;
        env.enterScope();

        while(l != null)
            {
            env.vars.put(l.fieldName, new VarEntry(l.fieldType));
            l = l.tail;
            }
       }
    b=expr[d,r]
        {
        env.leaveScope();
	
	if(!b.coerceTo(additionalFunction.result))
	    {semantError(#decl2, "The return type of " + n.getText() + " must match the declared return type of this function.");}
	    
	/* 
	    Start a new activation record, add variables for each of the
            formal parameters, and generate code for the body, sending
            the result to fp(-1) if there is one. 
	*/    
	
        }
    )
  ;


type returns [Type t]
    {
        Type q;
        t = env.getVoidType();
    }
  : k:ID
    {t = (Type) env.types.get(k.getText());}
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
    
    if(current.fieldType == null)
	{semantError(m, "Error, undefined field type.");}
    
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

