package Semant;

import antlr.Token;
import antlr.collections.AST;
import java.lang.String;

public class LineAST extends antlr.CommonAST {

    int line;
    public int getLine() { return line; }
    public void setLine(int l) { line = l; }

    public LineAST() {}
    public LineAST(int t, String txt) { initialize(t, txt); }
    public LineAST(Token t) { initialize(t); }
    public LineAST(AST t) { initialize(t); }

    public void initialize(int t, String txt) {
	setType(t);
	setText(txt);
	setLine(-1);
    }

    public void initialize(Token t) {
	setType(t.getType());
	setText(t.getText());
	setLine(t.getLine());
    }

    public void initialize(AST t) {
	setType(t.getType());
	setText(t.getText());
	setLine(0);
    }
}
