header {
  import Semant.Type;
  import Semant.Environment;
  import Semant.LineAST;
  import Semant.Entry;
  import Semant.VarEntry;
  import Semant.FunEntry;

  import Semant.*;
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
  | #( FIELD a=lvalue m:ID )
    { /* Verify lvalue is of record type with ID as a field */
    
    a = a.actual();
    
    if(!(a instanceof RECORD))
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

    t = d.fieldType;
    }
  | #( SUBSCRIPT a=lvalue b=expr)
    { /* Verify lvalue is an array type and expr is an int */
    if(!(a instanceof ARRAY))
        {semantError(#lvalue, "This is not an array: " + a);}

    if(!(b instanceof INT))
        {semantError(#lvalue, "Array indices must be integers");}

    t = ((ARRAY) a).element;
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
              op.equals("/") ||
              op.equals("|") ||
              op.equals("&")              
              ) {
             if (!(a instanceof Semant.INT) ||
                 !(b instanceof Semant.INT))
                 semantError(#expr, "operands of " + op + " must be integer");
             t = a;
         } else { // op is one of: = > < <> >= <=
            if(!b.coerceTo(a) && !a.coerceTo(b))
                {semantError(#expr, "operands of " + op + " must be of the same type.");}

            if(a instanceof VOID)
                {semantError(#expr, "operands of " + op + " cannot be applied to void types.");}

            t = env.getIntType();
         }
       }
     )
  | #( ASSIGN a=lvalue b=expr
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
  | #( RECORD fuckoff:ID (#(FIELD g:ID a=expr))*
       { /* Verify ID is a record type and that the listed fields match those
            of the record type */
        /*
        Type Rec = env.types.get(fuckoff.getText());

        if(Rec == null || !(Rec instanceof RECORD))
            {semantError(fuckoff, fuckoff.getText() + " is not a valid type.");}
        */

         Type recType = (Type)env.types.get(fuckoff.getText());
         if (recType == null)
             { semantError(#expr, "Undefined type: " + fuckoff.getText()); }
         t = recType.actual();
         
         // XXX: ensure that fields are all set (and ordered correctly)
         
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

        if(!(a instanceof INT))
            {semantError(anddie, "Array sizes must be integers.");}

        if(!(b.coerceTo(selected))
            {semantError(anddie, "Cannot initialize an array to a value of a type other than the type of the array.");}

         t = canidate;
       }
     )
  | #( "if" a=expr b=expr (c=expr)?
       { /* Verify the first expr is an int, that the second, if alone, is
            nothing, and the second and third match if there's a third */

        if (!(a instanceof INT))
            {semantError(#expr, "The predicate of an if statement must be of integer type.");}

        if (c == null && !(b instanceof VOID))
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
  | #( "while" a=expr b=expr
       { /* Verify the first expr is an int and that the second is nothing */

        if(!(a instanceof INT))
            {semantError(#expr, "The predicate of a while statement must be of integer type.");}

       if(!(b instanceof VOID))
            {semantError(#expr, "Foolishly, Tiger does not allow while statements to have a type. May I suggest a do-nothing assignment within the loop to force the value of the body of the while loop to be void?");}

         t = env.getVoidType();
       }
     )
  | #( "for" m:ID a=expr b=expr { env.enterScope(); env.vars.put(m.getText(), new VarEntry(env.getIntType())); } c=expr
       { /* Verify the first and second expressions are ints, define the ID as
            an int for the third, and verify its type is empty in a new scope.
         */

         if(!(a instanceof INT))
            {semantError(m, "The starting value of " + m.getText() + " must be an integer.");}

         if(!(b instanceof INT))
            {semantError(m, "The ending value of " + m.getText() + " must be an integer.");}

         env.leaveScope();

         t = env.getVoidType();
       }
     )
  | "break" { t = env.getVoidType(); }
  | #( "let"
       { env.enterScope(); }
       #(DECLS
       ( 
        
         #(innerD:DECLS 
             {  
                System.out.println("entering declaration group");
                AST ok = innerD.getFirstChild();
             }
             (decl)+ 
             { 
                System.out.println("leaving declaration group");
                while(ok != null)
                    {
                    decl2(ok);
                    ok = ok.getNextSibling();
                    // XXX: check for loopy types
                    }
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
        System.out.println("  adding type " + y.getText());
        String text = y.getText();
        NAME alias = new NAME(text);  
        env.types.put(text, alias);
       }
     )
  | #( "var" i:ID (a=type | "nil") b=expr
       { /* Verify the type of the expression matches the given type
            if non-nil, and add the var declaration to the current scope */

        if(a != null && !b.getClass().isInstance(a))
            {semantError(i, "You cannot place a value of one type in a variable of an incompatible type.");}

        env.vars.put(i.getText(), new VarEntry(b));
        System.out.println("  adding variable " + i.getText());
       }
     )
  | #( "function" n:ID {RECORD l;} l=fields (a=type | "nil" { a = null; } )
          {
          System.out.println("  adding function " + n.getText());
          if(a == null)
              {a = env.getVoidType();}
          FunEntry additionalFunction = new FunEntry(l, a);
          env.vars.put(n.getText(), additionalFunction);
          }
     )
  ;

////

decl2
    { Type a, b;
    a = null;
    }
  : #( "type" y:ID a=type
       { /* Add the given type to the current scope */
       System.out.println("  second pass type " + y.getText());
       NAME alias = (NAME) env.types.get(y.getText());
       alias.bind(a);
       }
     )
  | "var"
       {
        System.out.println("  second pass variable ");
       }
     
  | #( "function" n:ID FIELDS .
       { 
         /* Verify the arguments are actually types, enter the
            function in the current scope, start a new scope, add the formal
            parameters, check the body, and leave the scope */

        System.out.println("  second pass function " + n.getText());
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
        // XXX: make sure type of b matches return type
        }
    )
  ;

////

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

