import java.io.*;
import Semant.LineAST;
import Interp.*;

/// Main routine for the Tiger interpreter
class TI {

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
		    TigerTranslate tt = new TigerTranslate();
		    RecordInfo r = new RecordInfo("main");
		    Operand dest = r.newTmp();
		    tt.expr(ast, dest, r);

		    // Insert a push statement to ensure enough stack space
		    r.func.insert(new Psh(r.size()));

		    // Print the program
		    r.func.printAll();

		    // Execute the program
		    r.func.executeAll(true);
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
