class TigerParser extends Parser;
options {
    k=5;
    importVocab = Tiger;
    buildAST = true;
}

file : stmt EOF!;

stmt:
    BREAK
    | IF expr THEN stmt ( options {greedy=true;} : ELSE stmt)?
    | WHILE expr DO stmt
    | FOR ID ASSIGN expr TO expr DO stmt
    | LPAREN expr_seq RPAREN
    | ID LCURLY field_list RCURLY
//    | ID LBRACE expr RBRACE OF expr
    | LET decl_list IN expr_seq END
    | expr
    ;


expr: lvalue (ASSIGN expr)?
    | DASH expr
    | ID LPAREN expr_list RPAREN
    | term4
    ;

term4: term3 (logical_ops term3)*;

term3: term2 (compare_ops term2)*;

term2: term ((PLUS | DASH) term)*;

term: atom ((STAR | SLASH) atom)*;

atom: STRING
    | INTEGER
    | NIL
    | LPAREN! term4 RPAREN!
    ;

lvalue : (ID ((LBRACE expr RBRACE) | (DOT ID))+);

logical_ops
    : AND
    | OR
    ;

compare_ops
    : EQ
    | GT
    | LT
    | NE
    | GTE
    | LTE
    ;

expr_seq
    : stmt (SCOLON stmt)+
    ;

expr_list
    : expr (COMMA expr)+
    ;


field_list
    : ID EQ expr (COMMA ID EQ expr)*
    ;


decl_list
    : (decl)+
    ;

decl: type_decl
    | var_decl
    | func_decl
    ;

type_decl
    : ID
    | LCURLY type_fields RCURLY
    | ARRAY OF ID
    ;

type_fields
    : type_field (COMMA type_field)*
    ;

type_field
    : ID COLON ID
    ;

var_decl
    : VAR ID ASSIGN expr
    | VAR ID COLON ID ASSIGN expr
    ;

func_decl
    : FUNCTION ID LPAREN type_fields RPAREN (COLON ID)? EQ expr
    ;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class TigerLexer extends Lexer;
options {
  k=2;
}

tokens
{
    // loop keywords
    FOR      = "for";
    WHILE    = "while";
    BREAK    = "break";
    DO       = "do";
    END      = "end";

    // conditional keywords
    IF       = "if";
    ELSE     = "else";
    THEN     = "then";

    // other keywords
    ARRAY    = "array";
    FUNCTION = "function";
    IN       = "in";
    LET      = "let";
    NIL      = "nil";
    OF       = "of";
    TO       = "to";
    TYPE     = "type";
    VAR      = "var";
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
STRING  : '"' ( "\\\"" | ~'"') '"';

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
        