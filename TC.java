import java.io.*;
import Semant.LineAST;
import Interp.*;

/// Main routine for the Tiger MIPS compiler
class TC {
    public static boolean BLAH = true;
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
		    

		    TigerTranslate.addSystemFunction(r, "print", Sys.PRINT);
                    TigerTranslate.addSystemFunction(r, "printi", Sys.PRINTI);
                    TigerTranslate.addSystemFunction(r, "flush", Sys.FLUSH);
                    TigerTranslate.addSystemFunction(r, "getchar", Sys.GETCHAR);
                    TigerTranslate.addSystemFunction(r, "ord", Sys.ORD);
                    TigerTranslate.addSystemFunction(r, "chr", Sys.CHR);
                    TigerTranslate.addSystemFunction(r, "size", Sys.SIZE);
                    TigerTranslate.addSystemFunction(r, "substring", Sys.SUBSTRING);
                    TigerTranslate.addSystemFunction(r, "concat", Sys.CONCAT);
                    TigerTranslate.addSystemFunction(r, "not", Sys.NOT);
                    TigerTranslate.addSystemFunction(r, "exit", Sys.EXIT);

		    
		    
		    Operand dest = r.newTmp();
		    tt.expr(ast, dest, r);
		    r.append(new Rts());

		    // Insert a push statement to ensure enough stack space
		    r.allocateStack();


		    // Print MIPS assembly
		    r.func.printMips();

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
