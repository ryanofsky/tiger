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

  static void addSystemFunction(RecordInfo r, String name, int index)
  {
    RecordInfo activationRec = new RecordInfo(name, r);
    activationRec.append(new Sys(index)).append(new Rts());
    r.enterFunc(name, activationRec.func);
  }
}

lvalue [ RecordInfo r ] returns [ LValue output = null;]
    {
      Type type1, type2;
      LValue lval1;
    }
  : i:ID
    {
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

      output = new LValue(v.ty, r.findVar(i.getText()));
    }
  | #( FIELD lval1=lvalue[r] m:ID )
    {
      type1 = lval1.type.actual();

      if(!(type1 instanceof RECORD))
        {semantError(#lvalue, #lvalue.getText() + " is not a record.");}

      RECORD d = (RECORD) type1;

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
      output = new LValue(d.fieldType, new BlockRel(lval1.operand, new IntConstant(counter)));
    }
  | #( SUBSCRIPT lval1=lvalue[r] 
    {
	r.mark();
	Operand index = r.newTmp(); 
    } 
    type2=expr[index, r])
    {
      type1 = lval1.type;

      if(!(type1.actual() instanceof ARRAY))
        {semantError(#lvalue, "This is not an array: " + type1);}

      if(!(type2.actual() instanceof Semant.INT))
        {semantError(#lvalue, "Array indices must be integers");}

      isReadOnly = false;

      Type outType = ((ARRAY) type1.actual()).element;

      output = new LValue(outType, new BlockRel(lval1.operand, index));
      //r.release();
    }
  ;

expr [ Operand d, RecordInfo r ] returns [Type t]
    {
      Type a, b, c = null;
      t = env.getVoidType();
      LValue p;
            
    }
  : "nil"
    {
      t = env.getNilType();
      r.append( new Mov(d, new NilConstant() ) );
    }
  | p=lvalue[r]
    {
      t = p.type;
      Mov abc = new Mov(d,p.operand);
      System.out.println("adding mov: " + abc.string());
      r.append(abc);
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
    {
      if ( !(a.actual() instanceof Semant.INT))
        semantError(#expr, "Operand of unary minus must be integer");
      t = env.getIntType();

      r.append( new Neg(d, d));
    }
    )
  | #( BINOP 
    {
    if(d == null)
	{throw new IllegalArgumentException("Null destination.");}
	
	Operand temp1 = r.newTmp();
    }	
    a=expr[temp1,r]
    {
      String op = #expr.getText();
      Label lazyLabel = null;
      if (op.equals("|"))
      {
        lazyLabel = new Label();
        r.append(new Bnz(new LabelOperand(lazyLabel), temp1));
      }
      else if (op.equals("&"))
      {
        lazyLabel = new Label();
        r.append(new Bz(new LabelOperand(lazyLabel), temp1));
      }

      Operand tmp;
      if (lazyLabel != null)
        tmp = temp1;
      else
      {
        r.mark();
        tmp = r.newTmp();
      }

    } b=expr[tmp,r]
    {

      if ( op.equals("+") ||
           op.equals("-") ||
           op.equals("*") ||
           op.equals("/") ||
           op.equals("|") ||
           op.equals("&")
         )
      {
        if (!(a.actual() instanceof Semant.INT) ||
            !(b.actual() instanceof Semant.INT))
          semantError(#expr, "operands of " + op + " must be integer");
        t = a;
      }
      else // op is one of: = > < <> >= <=
      {
        if(!b.coerceTo(a) && !a.coerceTo(b))
            {semantError(#expr, "operands of " + op + " must be of the same type.");}

        if(a.actual() instanceof VOID)
            {semantError(#expr, "operands of " + op + " cannot be applied to void types.");}

        t = env.getIntType();
      }

    boolean doingStrings = (a.actual() instanceof Semant.STRING);


      if (lazyLabel != null)
      {
        r.append(lazyLabel);
	r.append(new Mov(d, temp1));
	
      }
      else
      {
        int opCode;
        if (op.equals("+"))
          opCode = Binop.ADD;
        else if(op.equals("-"))
          opCode = Binop.SUB;
        else if(op.equals("*"))
          opCode = Binop.MUL;
        else if(op.equals("/"))
          opCode = Binop.DIV;
        else if(op.equals("="))
          opCode = Binop.EQU;
        else if(op.equals("<>"))
          opCode = Binop.NEQ;
        else if(op.equals("<"))
          opCode = Binop.LT;
        else if(op.equals(">="))
          opCode = Binop.LEQ;
        else if(op.equals(">"))
          opCode = Binop.GT;
        else if(op.equals(">="))
          opCode = Binop.GEQ;
        else // can never happen
          throw new Error("Internal Error. Unrecognized operator '" + op + "'");

        r.append(new Binop(opCode, d, temp1, tmp, doingStrings));
        r.release();
      }
    }
    )
  | #( ASSIGN {isReadOnly = false;} p=lvalue[r]
    {
      if(isReadOnly)
        {semantError(#expr, "You cannot assign to a read only variable.");}
    }
    b=expr[p.operand,r]
    {
      if(!b.coerceTo(p.type))
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
      int argCount = -1;

      r.mark();
      FrameRel lastOp = null; // first argument goes here, other arguments go before that
      for(RECORD params = jello; params != null; params = params.tail)
        lastOp = (FrameRel) r.newEndTmp();
      Operand retVal = theFunction.result.actual() instanceof VOID ? null : r.newEndTmp();

	if(retVal != null)
	    {argCount = -2;}

      r.newEnd();
      
      
    } ( { FrameRel fr = new FrameRel(argCount); r.functionArgs.add(fr); System.out.println("ArgCount: " + argCount);} a=expr[fr,r]
    {
      if(jello == null)
          {semantError(z, "Too many arguments for function '" + z.getText() + "' (" + argCount + " expected)");}

      if(!a.coerceTo(jello.fieldType))
          {semantError(z, "Argument " + (argCount + 1) + " for function '" + z.getText() + "' has the wrong type.");}

      jello = jello.tail;
      --argCount;
    } )*
    {
      if(jello != null)
          {semantError(z, "Too few arguments specified for function '" + z.getText() + "'");}

      t = result;

      // code based on professor's RecordInfo.getFunc() function.
      // It is no good because it doesn't return a depth value
      // which is needed to make correct static links
      LabelOperand func = null;
      int depth = 0;
      for (RecordInfo ri = r; ri != null; ri = ri.parent)
      {
        Object o = ri.topScope.get((z.getText()).trim());
        if (o != null)
        {
          func = new LabelOperand((Label)o);
          break;
        }
        ++depth;
      }

    if(func == null)
	{throw new IllegalArgumentException("Undeclared function: " + z.getText());}

      r.append(new Jsr(func, depth));
      System.out.println("Depth: " + depth);
      if (retVal != null) r.append(new Mov(d, retVal));
      r.release();
    }
    )
  | #( SEQ { t = env.getVoidType(); } (t=expr[d,r])* )
  | #( RECORD fuckoff:ID
    {
      Type recType = (Type) env.types.get(fuckoff.getText());

      if (recType == null)
        { semantError(#expr, "Undefined type: " + fuckoff.getText()); }

      if(!(recType.actual() instanceof RECORD))
        {semantError(#expr, fuckoff.getText() + " is not a valid name for a record.");}

      RECORD ourRec = (RECORD) recType.actual();
      t = ourRec;

      /* Create the new record with a rec statement */
      int size = 1;
      RECORD tempRec = ourRec;
      
      while(tempRec.tail != null)
	{
	tempRec = tempRec.tail;
	size++;
	}
      
      r.append(new Rec(d, size));
      
      int sectionNumber = 0;
      
    }
    (#(FIELD g:ID {BlockRel blr = new BlockRel(d, new IntConstant(sectionNumber));} a=expr[blr,r])
    {
	sectionNumber++;
	
      if(ourRec == null)
        {semantError(#expr, "You have assigned to more fields than this record has in its definition.");}

      if(!ourRec.fieldName.equals(g.getText()))
        {semantError(#expr, "The field names given in the initialization of this record don't match the field types in its declaration.");}

      if(!a.coerceTo(ourRec.fieldType))
        {semantError(#expr, "The type of the value assigned to " + ourRec.fieldName + " does not match the declared type of the field.");}

      ourRec = ourRec.tail;
    } )*
    {
      if(ourRec != null)
          {semantError(#expr, "You must assign to all of the record's fields.");}

      t = recType;
    }
    )
  | #( NEWARRAY anddie:ID {Operand size = r.newTmp(); } a=expr[size,r] b=expr[d,r]
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
       
       Operand value = d;
       r.append(new Arr(d, size, value));
    }
    )
  | #( "if" 
    {
    r.mark();
    Operand boolTemp = r.newTmp();
    }
    a=expr[boolTemp,r]
    {
      Label ifElse = new Label();
      Label ifExit = new Label();
      r.append(new Bz(new LabelOperand(ifElse), boolTemp));
      r.release();
    } b=expr[d,r]
    {
      r.append(new Jmp(new LabelOperand(ifExit)))
       .append(ifElse);
    } (c=expr[d,r])?
    {
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
      r.append(ifExit);
    }
    )
  | #( "while"
    {
      Label topWhile = new Label();
      Label bottomWhile = new Label();
      r.append(topWhile);
      r.mark();
      Operand wTemp = r.newTmp();
    } a=expr[wTemp,r]
    {
      env.enterScope();
      env.vars.put("break viable", new LabelOperand(bottomWhile));
      r.append(new Bz(new LabelOperand(bottomWhile), wTemp));
      r.release();
    } b=expr[d,r]
    {
      if(!(a.actual() instanceof Semant.INT))
        {semantError(#expr, "The predicate of a while statement must be of integer type.");}

      if(!(b.actual() instanceof VOID))
        {semantError(#expr, "Foolishly, Tiger does not allow while statements to have a type. May I suggest a do-nothing assignment within the loop to force the value of the body of the while loop to be void?");}

      //added to allow break checking.
      env.leaveScope();
      t = env.getVoidType();

     r.append(new Jmp(new LabelOperand(topWhile)))
      .append(bottomWhile);
    }
    )
  | #( "for" m:ID
    {
      Label bottomFor = new Label();

      env.enterScope();
      env.vars.put(m.getText(), new VarEntry(env.getIntType()));
      env.vars.put("break viable", new LabelOperand(bottomFor));
      env.vars.put(m.getText() + " isLocked", "true");

      r.enterScope();
      Operand loopVar = r.newVar(m.getText());
    } a=expr[loopVar,r]
    {
      Label topFor = new Label();
      r.append(topFor);
      r.mark();
      Operand tempVar = r.newTmp();
    } b=expr[tempVar,r]
    {
      r.append(new Binop(Binop.GT, tempVar, loopVar, tempVar, false))
       .append(new Bnz(new LabelOperand(bottomFor), tempVar));
    } c=expr[d,r]
    {
      if(!(a.actual() instanceof Semant.INT))
        {semantError(m, "The starting value of " + m.getText() + " must be an integer.");}

      if(!(b.actual() instanceof Semant.INT))
        {semantError(m, "The ending value of " + m.getText() + " must be an integer.");}

      env.leaveScope();
      t = env.getVoidType();

      r.append(new Binop(Binop.ADD, loopVar, loopVar, new IntConstant(1), false))
       .append(new Jmp(new LabelOperand(topFor)))
       .append(bottomFor);

      r.leaveScope();
      r.release();
    }
    )
  | "break"
    {
      LabelOperand breakTo = (LabelOperand) env.vars.get("break viable");

      if(breakTo == null)
        {semantError(#expr, "Break may only be used from within a while or for loop.");}

      t = env.getVoidType();

      r.append(new Jmp(breakTo));
    }
  | #( "let"
    {
      env.enterScope();
      r.mark();
      r.enterScope();
    }
      #(DECLS (
        #(innerD:DECLS
        {AST ok = innerD.getFirstChild();}
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
              } //while.
            } //if.
          } //for.
        } //outside of all loops.
        )
      )*)
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
    {  Type a = null, b;  }
  : #( "type" y:ID
    {
      String text = y.getText();
      NAME alias = new NAME(text);
      env.types.put(text, alias);
    }
    )
  | #( "var" i:ID (a=type | "nil") {Operand v = r.newVar(i.getText());}
  b=expr[v,r]
    {
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
      
    //.....
    RecordInfo activationRec = new RecordInfo(n.getText(), r);
    r.enterFunc((n.getText()).trim(), activationRec.func);
    r.putThing(" " + n.getText(), activationRec);
    }
    )
  ;

decl2 [ Operand d, RecordInfo r ] returns [String s = null;]
    { Type a = null, b; }
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
       i:ID { Operand v = r.findVar(i.getText()); }
       (ID | "nil")

    )
  | #( "function" n:ID FIELDS .
    {    
      FunEntry additionalFunction = (FunEntry)env.vars.get(n.getText());
      RECORD l = additionalFunction.formals;
      env.enterScope();

      //RecordInfo activationRec = new RecordInfo(n.getText(), r);
      RecordInfo activationRec = (RecordInfo) r.getThing(" " + n.getText());
      Operand retVal = additionalFunction.result.actual() instanceof VOID ? null :new FrameRel(-1);

      // put argument offsets in symbol table
      int argOffset = retVal == null ? 0 : -1;
      while(l != null)
      {
        env.vars.put(l.fieldName, new VarEntry(l.fieldType));
        activationRec.topScope.put(l.fieldName, new Integer(--argOffset));
        l = l.tail;
      }

    } b=expr[retVal, activationRec]
    {
      env.leaveScope();

      if(!b.coerceTo(additionalFunction.result))
        {semantError(#decl2, "The return type of " + n.getText() + " must match the declared return type of this function.");}

      activationRec.append(new Rts());
      activationRec.allocateStack();
	System.out.println("Declaring function: " + n.getText());
      r.enterFunc((n.getText()).trim(), activationRec.func);
      
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

