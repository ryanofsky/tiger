header {
  import Semant.LineAST;
  import Interp.*;
}

class TigerTranslate extends TreeParser;

options {
  importVocab = Tiger;
  ASTLabelType = "Semant.LineAST";
}

lvalue [ RecordInfo r ] returns [ Operand lval ]
  { Operand o; lval = null; }
  : i:ID { lval = r.findVar(i.getText()); }
  | #( FIELD o=lvalue[r] ID
     { /* Determine the offset into the field using the ID, then
	  return new BlockRel(o1, new INT(offset)) */ } )
  | #( SUBSCRIPT o=lvalue[r]
     { Operand tmp = r.newTmp(); }
      expr[tmp, r]
     { lval = new BlockRel(o, tmp); }
     )
  ;

// d is where this expression should place its results, if any

expr [ Operand d, RecordInfo r ]
  { Operand o; }
  : "nil" { r.append( new Mov(d, new NilConstant() ) ); }
  | o=lvalue[r] { r.append( new Mov(d, o)); } 
  | s:STRING { r.append( new Mov(d, new StringConstant(s.getText()))); }
  | n:NUMBER
    { r.append(new Mov(d, new IntConstant(Integer.parseInt(n.getText(),10))));}
  | #( NEG expr[d,r] ) { r.append( new Neg(d, d)); }
  | #( BINOP
       expr[d,r]
       { r.mark(); Operand tmp = r.newTmp(); }
       expr[tmp, r]
       {
	 // FIXME: Change this to use the right operator
	 r.append( new Binop(Binop.ADD, d, d, tmp));
	 r.release();
       }
     )       
  | #( ASSIGN o=lvalue[r] expr[o,r] )
  | #( CALL ID (expr[d,r])*
       { /* Allocate space for each of the arguments, evaluate each, and
            call the function with a jsr.  Find the label with r.getFunc */ } )
  | #( SEQ (expr[d,r])* )
  | #( RECORD ID { /* Create the new record with a rec statement */ }
       (#(FIELD ID { /* Store each expression with the proper offset */ }
          expr[d,r]) )*
     )
  | #( NEWARRAY ID expr[d,r] expr[d,r]
       { /* Create a new array with an arr statement */ } )
  | #( "if" expr[d,r] expr[d,r] (expr[d,r])?
       { /* Evaluate the first expression, bz past the first
            expression's code, unconditional branch to the end,
            evalute the second expression, if any,
            then finally add the trailing label. */ } )
  | #( "while" expr[d,r] expr[d,r]
       { /* Evaluate the first expression, bz to the end,
            evaluate the second expression, then branch back to
            the beginning. */ } )
  | #( "for" ID expr[d,r] expr[d,r] expr[d,r]
       { /* Enter a new scope, create, and add code that initializes the
            index variable to the value of the second expression.
            Compare the index variable with the second expression and bnz to
            the end.  Generate code for the third expression, code that
            increments the index by one, then branch to the beginning. */ } )
  | "break" { /* Unconditional branch to the innermost loop exit */ }
  | #( "let"
       { r.mark(); r.enterScope(); }
       #(DECLS (#(DECLS (decl[d,r])+ ))* )
       expr[d,r]
       { r.release(); r.leaveScope(); }
     )
  ;

decl [ Operand d, RecordInfo r ]
  : #( "type" ID type )
  | #( "var"
       i:ID { Operand v = r.newVar(i.getText()); }
       (ID | "nil")
       expr[v,r]
     )
  | #( "function" ID fields (ID | "nil") expr[d,r]
       { /* Start a new activation record, add variables for each of the
            formal parameters, and generate code for the body, sending
            the result to fp(-1) if there is one. */ }
     )
  ;

type
  : ID
  | fields
  | #( "array" ID )
  ;

fields : #( FIELDS ( #(FIELD ID ID) )* ) ;
