class TigerParser extends Parser;
options {
    k=5;
    importVocab = Tiger;
    buildAST = true;
}

file : expr EOF!;

      
expr: (ID array_index "of") => ID array_index "of" expr  // array type defn
    | ID LCURLY field_list RCURLY                        // record type defn
    | expr1                                              // binary expression
    | "if" expr "then" expr ( options {greedy=true;} : "else" expr)? 
    | "for" ID ASSIGN expr "to" expr "do" expr           
    | "while" expr "do" expr                             
    | "break"
    | "let" decl_list "in" expr_seq "end"
    ;

// todo: after eating a binary operator, $setType to BINOP
expr1: expr2 ((AND | OR) expr2)*;
expr2: expr3 ((EQ | GT | LT | NE | GTE | LTE) expr3)?;
expr3: expr4 ((PLUS | DASH) expr4)*;
expr4: atom ((STAR | SLASH) atom)*;

atom: "nil"
    | INTEGER
    | STRING
    | DASH atom
    | LPAREN expr_seq RPAREN         
    | ID LPAREN (expr_list)? RPAREN // function call
    | lvalue
    ;

lvalue:
  ID (array_index | (DOT ID))*; // lvalue

expr_list
    : expr (COMMA expr)+
    ;

expr_seq
    : expr (SCOLON expr)*
    ;

array_index
    : LBRACE expr RBRACE
    ;

field_list
    : ID EQ expr (COMMA ID EQ expr)*
    ;

decl_list
    : (decl)+
    ;

decl: var_decl
    | type_decl
    | func_decl
    ;

var_decl
    : "var" ID ASSIGN expr
    | "var" ID COLON ID ASSIGN expr
    ;

func_decl
    : "function" ID LPAREN type_fields RPAREN (COLON ID)? EQ expr
    ;

type_fields
    : type_field (COMMA type_field)*
    ;

type_field
    : ID COLON ID
    ;

type_decl
    : "type" ID EQ type
    ;
    
type: ID
    | LCURLY type_fields RCURLY
    | "array" "of" ID
    ;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class TigerLexer extends Lexer;
options {
  k=2;
}

protected
LETTER  : 'a'..'z'
        | 'A'..'Z'
        ;

protected
DIGIT   : '0'..'9';

ID
options {testLiterals=true;}
        : LETTER (LETTER | DIGIT | '_')*
        {System.out.println ("Found Identifer:" + text); }
        ;

INTEGER : (DIGIT)+;
STRING
options {testLiterals=true;}
        : '"' ( "\\\"" | ~'"') '"'
        ;

// todo: handle string escape sequences with $setText(x) $getText() 

// binary operators
PLUS    : '+'  { System.out.println ("Found:" + text); };
DASH    : '-'  { System.out.println ("Found:" + text); };
STAR    : '*'  { System.out.println ("Found:" + text); };
SLASH   : '/'  { System.out.println ("Found:" + text); };
AND     : '&'  { System.out.println ("Found:" + text); };
OR      : '|'  { System.out.println ("Found:" + text); };
EQ      : '='  { System.out.println ("Found:" + text); };
GT      : '>'  { System.out.println ("Found:" + text); };
LT      : '<'  { System.out.println ("Found:" + text); };
NE      : "<>" { System.out.println ("Found:" + text); };
GTE     : ">=" { System.out.println ("Found:" + text); };
LTE     : "<=" { System.out.println ("Found:" + text); };
ASSIGN  : ":=" { System.out.println ("Found:" + text); };

// punctuation
COMMA   : ',' { System.out.println ("Found:" + text); };
COLON   : ':' { System.out.println ("Found:" + text); };
SCOLON  : ';' { System.out.println ("Found:" + text); };
DOT     : '.' { System.out.println ("Found:" + text); };
LPAREN  : '(' { System.out.println ("Found:" + text); };
RPAREN  : ')' { System.out.println ("Found:" + text); };
LBRACE  : '[' { System.out.println ("Found:" + text); };
RBRACE  : ']' { System.out.println ("Found:" + text); };
LCURLY  : '{' { System.out.println ("Found:" + text); };
RCURLY  : '}' { System.out.println ("Found:" + text); };

protected
NEWLINE : '\n' { newline(); };

WHITE   : ( ' '
          | '\t'
          | NEWLINE
          | '\r'
          )+
        { $setType(Token.SKIP); System.out.println ("Found Whitespace"); }
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

COMMENT : SCOMMENT
        | LCOMMENT
        { $setType(Token.SKIP); System.out.println ("Found Comment"); }
        ;
        