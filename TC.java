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
                    tt.addSystemFunctions(r);
                    
                    Operand dest = r.newTmp();
                    tt.expr(ast, dest, r);
                    r.append(new Rts());

                    // Insert a push statement to ensure enough stack space
                    r.allocateStack();

                    for(int x = 0; x < r.functions.size(); ++x )
                    {
                      Label f = (Label)r.functions.get(x);
                      f.printMips();
                    }

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
