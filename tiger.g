class TigerParser extends Parser;
options {
    k=5;
    importVocab = Tiger;
    buildAST = true;
}

file : expr EOF!;

expr: (ID LBRACE expr RBRACE "of") => ID LBRACE^ expr RBRACE! "of"! expr { #expr.setType(NEWARRAY); } // array type defn
    | ID LCURLY^ field_list RCURLY! { #expr.setType(RECORD); }                      // record type defn
    | expr1                                        // binary expression
    | "if"^ expr "then"! expr ( options {greedy=true;} : "else"! expr)? 
    | "for"^ ID ASSIGN! expr "to"! expr "do"! expr       
    | "while"^ expr "do"! expr                             
    | "break"
    | "let"^ decls "in"! expr_list "end"!
    ;

expr1: expr2 ((AND^ | OR^) expr2 { #expr1.setType(BINOP); } )*;
expr2: expr3 ((EQ^ | GT^ | LT^ | NE^ | GTE^ | LTE^) expr3 { #expr2.setType(BINOP); } )?;
expr3: expr4 ((PLUS^ | DASH^) expr4 { #expr3.setType(BINOP); } )*;
expr4: atom ((STAR^ | SLASH^) atom { #expr4.setType(BINOP); } )*;

atom: "nil"
    | NUMBER
    | STRING
    | DASH^ atom { #atom.setType(NEG); }
    | LPAREN! expr_list RPAREN!         
    | ID LPAREN^ (expr_list)? RPAREN! { #atom.setType(CALL); } // function call
    | lvalue (ASSIGN^ atom)?
    ;

/*
lvalue:
    lvalue2;
*/

//id:ID (a:array_index {#lvalue.setType(SUBSCRIPT);}| (DOT! ID) {#lvalue.setType(FIELD);})*

lvalue:
  ID (LBRACE^ expr RBRACE! {#lvalue.setType(SUBSCRIPT);} | (DOT^ ID) {#lvalue.setType(FIELD);})*
  ; // lvalue

//need to make virtual tokens to add headers.
expr_list
    : expr ((COMMA! | SCOLON!) expr)*
    ;

/* can't put back in due to recursion.
expr_seq
    : expr (SCOLON! expr)*
    ;
*/

decls : (decls1 | decls2 | decls3)?
      {#decls.setType(DECLS);}
      ;

decls1 : func_decls (decls2 | decls3)?;
decls2 : type_decls (decls1 | decls3)?;
decls3 : (var_decls)+ (decls1 | decls2)?;


//need to create virtual token to avoid overwriting.
func_decls
    : (func_decl)+
    {#func_decls.setType(DECLS);}
    ;

//need to create virtual token to avoid overwriting.
type_decls
    : (type_decl)+
    {#type_decls.setType(DECLS);}
    ;

//need to create virtual token to avoid overwriting.
var_decls
    : var_decl
    {#var_decls.setType(DECLS);}
    ;

field_list
    : field (COMMA! field)* 
    ;

field
    : ID EQ^ expr {#field.setType(FIELD);};

var_decl
    : "var"^ ID ASSIGN! expr
    | "var"^ ID COLON! ID ASSIGN! expr
    ;

func_decl
    : "function"^ ID LPAREN! (type_fields)? RPAREN! (COLON! ID)? EQ! expr
    ;

//need to create virtual token to add header
type_fields
    : type_field (COMMA! type_field)*
    ;

type_field
    : ID COLON! ID
    ;

type_decl
    : "type"^ ID EQ! type
    ;
    
type: ID
    | LCURLY! type_fields RCURLY!
    | "array" "of"! ID
    ;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class TigerLexer extends Lexer;
options {
  k=2;
  testLiterals=false;
}

protected
LETTER  : 'a'..'z'
        | 'A'..'Z'
        ;

protected
DIGIT   : '0'..'9';

ID
options {testLiterals=true;}
        : (LETTER (LETTER | DIGIT | '_')*)
        ;

NUMBER : (DIGIT)+;

STRING  : '"' ( ESCAPE | ~('"'|'\\') )* '"' 
        //{ $setText($getText().subString(1, ($getText().length() - 2) ) );}
        ;

protected
ESCAPE
    :    '\\'
         ( 'n'  { $setText("\n"); }
         | 'r'  { $setText("\r"); }
         | 't'  { $setText("\t"); }
         | '"'  { $setText("\""); }
         | '\\' { $setText("\\"); }
         | '^' ctl:('A'..'Z' | '[' | '\\' | ']' | '^' | '_') { $setText("control character" + ctl.getText()); }
         | dig:(DIGIT DIGIT DIGIT) //{ $setText(new String("" + (char) Integer.parseInt(dig.getText().substring(1, dig.getText().length())))); }
         | (' ' | '\t' | '\n' | '\r' | '\f') '\\' { $setText(""); }
         )
    ;

// todo: handle string escape sequences with $setText(x) $getText() 

// binary operators
PLUS    : '+';
DASH    : '-';
STAR    : '*';
SLASH   : '/';
AND     : '&';
OR      : '|';
EQ      : '=';
GT      : '>';
LT      : '<';
NE      : "<>";
GTE     : ">=";
LTE     : "<=";
ASSIGN  : ":=";

// punctuation
COMMA   : ',';
COLON   : ':';
SCOLON  : ';';
DOT     : '.';
LPAREN  : '(';
RPAREN  : ')';
LBRACE  : '[';
RBRACE  : ']';
LCURLY  : '{';
RCURLY  : '}';

protected
NEWLINE : '\n' { newline(); };

WHITE   : ( ' '
          | '\t'
          | NEWLINE
          | '\r'
          )+
        { $setType(Token.SKIP); }
        ;

protected
SCOMMENT: "//" (~'\n')* '\n'
        ;

protected
LCOMMENT: "/*"
          ( LCOMMENT
          | NEWLINE
          | '*' ~'/'
          | ~'*'
          )*
          "*/"
        ;

COMMENT : SCOMMENT
        | LCOMMENT
        { $setType(Token.SKIP); }
        ;
        