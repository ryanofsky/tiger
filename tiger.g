class TigerParser extends Parser;
options {
    k=2;
    importVocab = Tiger;
    buildAST = true;
}

file : op_expr EOF!;

// in some of the rules below, instead of manually specifying the
// tree structure in actions, we use extraneous pieces of punctuation
// as temporary head nodes and call setType on them to give them
// meaningful values. this is not so intuitive, but makes the rules
// shorter and more readable

expr: (ID LBRACE op_expr RBRACE "of") => ID LBRACE^ op_expr RBRACE! "of"! op_expr { #expr.setType(NEWARRAY); }
    | ID LCURLY^ field_list RCURLY! { #expr.setType(RECORD); }
    | "nil"
    | NUMBER
    | STRING
    | DASH^ expr { #expr.setType(NEG); }
    | LPAREN! (expr_seq) RPAREN!
    | ID LPAREN^ (expr_list)? RPAREN! { #expr.setType(CALL); } // function call
    | lvalue (ASSIGN^ op_expr)?
    | "if"^ op_expr "then"! op_expr ( options {greedy=true;} : "else"! op_expr)?
    | "for"^ ID ASSIGN! op_expr "to"! op_expr "do"! op_expr
    | "while"^ op_expr "do"! op_expr
    | "break"
    | "let"^ decls "in"! expr_seq "end"!
    ;

// op_expr is more general than expr because it includes expressions formed from binary operators
op_expr: expr1;
expr1: expr2 ( options {greedy=true;} : (AND^ | OR^) expr2 { #expr1.setType(BINOP); } )*;
expr2: expr3 ( options {greedy=true;} : (EQ^ | GT^ | LT^ | NE^ | GTE^ | LTE^) expr3 { #expr2.setType(BINOP); } )?;
expr3: expr4 ( options {greedy=true;} : (PLUS^ | DASH^) expr4 { #expr3.setType(BINOP); } )*;
expr4: expr  ( options {greedy=true;} : (STAR^ | SLASH^) expr { #expr4.setType(BINOP); } )*;

lvalue:
    ID (LBRACE^ op_expr RBRACE! {#lvalue.setType(SUBSCRIPT);} | (DOT^ ID) {#lvalue.setType(FIELD);})*
    ;

expr_list
    : op_expr (COMMA! op_expr)*
    ;

expr_seq
    : op_expr (SCOLON! op_expr)* { #expr_seq = #([SEQ], #expr_seq); }
    ;

decls: (func_decls | var_decls | type_decls)*
     { #decls = #([DECLS], #decls); }
     ;

var_decls
    : (options {greedy=true;} : var_decl)+
    { #var_decls = #([DECLS], #var_decls); }
    ;
var_decl!
    : "var" a:ID b:type_descriptor ASSIGN c:op_expr
    {#var_decl = #([LITERAL_var], #a, #b, #c);}
    ;

func_decls
    : (options {greedy=true;} : func_decl)+
    { #func_decls = #([DECLS], #func_decls); }
    ;

func_decl!
    : "function" a:ID LPAREN b:type_field_list RPAREN c:type_descriptor EQ d:op_expr
    { #func_decl = #([LITERAL_function], #a, #b, #c, #d); }
    ;

type_decls
    : (options {greedy=true;} : type_decl)+
    { #type_decls = #([DECLS], #type_decls); }
    ;

type_decl
    : "type"^ ID EQ! type
    ;

type: ID
    | LCURLY! type_field_list RCURLY!
    | "array"^ "of"! ID
    ;

// type field lists are used in record and function definitions
// example: function try(c:int) = c
// example: type person = {name:string, age:int}

type_field_list
    : (type_field (COMMA! type_field)*)?
    { #type_field_list = #([FIELDS], #type_field_list); }
    ;

type_field
    : ID COLON! ID
    { #type_field = #([FIELD], #type_field); }
    ;

// field lists are used in record type instantiations
// example: var rec1:person := person {name="Nobody", age=1000}

field_list
    : field (COMMA! field)*
    ;

field
    : ID EQ! op_expr
    { #field = #([FIELD], #field); }
    ;

// types of var declarations and return types of functions are specified
// only optionally. this rule will return the type if it is specified
// otherwise it will return nil
type_descriptor!
    : (COLON! a:ID) { #type_descriptor = #a; }
    | { #type_descriptor = #([LITERAL_nil]); }
    ;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class TigerLexer extends Lexer;
options {
  k=2;
  testLiterals=false;
  charVocabulary = '\3'..'\377';
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
        {
          String s = $getText;
          setText(s.substring(1, s.length() - 1));
        }
        ;

protected
ESCAPE
    :    '\\'
         ( 'n'  { $setText("\n"); }
         | 'r'  { $setText("\r"); }
         | 't'  { $setText("\t"); }
         | '"'  { $setText("\""); }
         | '\\' { $setText("\\"); }
         | '^' a:'@'..'_'
           {
             char i = (char)(a - 64);
             $setText("" + i);
           }
         | (b:DIGIT c:DIGIT d:DIGIT)
           {
             char i = (char)Integer.parseInt(b.getText() + c.getText() + d.getText());
             $setText("" + i);
           }
         | (' ' | '\t' | '\n' | '\r' | '\f')+ '\\' { $setText(""); }
         )
    ;

// todo: handle string escape sequences with $setText(x) $getText()

// binary operators
PLUS    : '+';
DASH    : '-';
STAR    : '*';
SLASH options {testLiterals=true;}  : '/';
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
SCOMMENT: "//" (~'\n')* '\n';

protected
LCOMMENT: "/*"
          ( LCOMMENT
          | NEWLINE
          | '*' ~'/'
          | ~'*'
          )*
          "*/"
        ;

COMMENT : (SCOMMENT | LCOMMENT )
        { $setType(Token.SKIP); }
        ;
        