class TigerASTGram extends TreeParser;

options {
  exportVocab = Tiger;
}

lvalue
  : ID
  | #( FIELD lvalue ID )
  | #( SUBSCRIPT lvalue expr)
  ;

expr
  : "nil"
  | lvalue
  | STRING
  | NUMBER
  | #( NEG expr )
  | #( BINOP expr expr )
  | #( ASSIGN lvalue expr )
  | #( CALL ID (expr)* )
  | #( SEQ (expr)* )
  | #( RECORD ID (#(FIELD ID expr))* )
  | #( NEWARRAY ID expr expr )
  | #( "if" expr expr (expr)? )
  | #( "while" expr expr )
  | #( "for" ID expr expr expr )
  | "break"
  | #( "let" #(DECLS (#(DECLS (decl)+ ))* ) expr )
  ;

decl
  : #( "type" ID type )
  | #( "var" ID (ID | "nil") expr )
  | #( "function" ID fields (ID | "nil") expr )
  ;

type
  : ID
  | fields
  | #( "array" ID )
  ;

fields : #( FIELDS ( #(FIELD ID ID) )* ) ;
