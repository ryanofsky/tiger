import java.io.*;
import Semant.LineAST;

/// Main routine for the Tiger compiler
class TC {

    public static void main(String[] args) {
	try {
	    InputStream i;
	    if (args.length == 0) {
		i = new DataInputStream(System.in);
	    } else {
		i = new FileInputStream(args[0]);
	    }
	    TigerLexer lexer = new TigerLexer(i);
	    TigerParser parser = new TigerParser(lexer);
	    parser.setASTNodeClass("Semant.LineAST");

	    try {

		parser.file();
		LineAST ast = (LineAST)parser.getAST();

		if (ast != null) {
		    TigerSemant ts = new TigerSemant();
		    ts.expr(ast);
		}

	    } catch (antlr.TokenStreamRecognitionException e) {
		System.err.println( lexer.getLine() + ":" + e );
		System.exit(1);
	    } catch (antlr.RecognitionException e) {
		System.err.println( e.toString() );
		System.exit(1);
	    }

	} catch (Exception e) {
	    e.printStackTrace();
	    System.err.println("exception: " + e);
	}
    }
}
