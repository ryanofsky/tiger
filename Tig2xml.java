import java.io.*;
import antlr.collections.AST;

/// Main routine for scanning and parsing a Tiger file, generating XML
class Tig2xml {

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

      parser.file();
      antlr.CommonAST ast = (antlr.CommonAST)parser.getAST();

      if (ast != null) {
        astToXML(System.out, ast, 0);

        // Run the AST grammar checker
        TigerASTGram gwalk = new TigerASTGram();
        gwalk.expr(ast);
      }
    } catch (Exception e) {
      e.printStackTrace();
      System.err.println("exception: " + e);
    }
  }

  /// Print an AST in XML form
  public static void astToXML(PrintStream o, AST a, int indent) {
    for (int i = 0 ; i < indent ; i++) o.print(" ");
    String value = a.getText();
    int ttype = a.getType();
    
    String tokenName = null;
    
    try
        { tokenName = TigerTokenText.tokenNames[ttype];}
    catch(ArrayIndexOutOfBoundsException e)
        {
         System.out.println("Bad Index: " + ttype);
         System.out.println("Max Size: " + TigerTokenText.tokenNames.length);
         System.out.println("Here's what it doesn't like: " + value);
            
         throw e;   
        }

    o.print("<" + tokenName);
    if (ttype == TigerTokenTypes.ID || ttype == TigerTokenTypes.STRING ||
      ttype == TigerTokenTypes.NUMBER) {
      o.print(">");
      printXMLstring(o, value);
      o.println("</" + tokenName + ">");
    } else {
      if (ttype == TigerTokenTypes.BINOP) {
        o.print(" o=\"");
        printXMLstring(o, a.getText());
        o.print("\"");
      }
      if (a.getFirstChild() == null) {
        o.println("/>");
      } else {
        o.println(">");
        AST c = a.getFirstChild();
        while ( c != null ) {
          astToXML(o, c, indent + 1);
          c = c.getNextSibling();
        }
        for (int i = 0 ; i < indent ; i++) o.print(" ");
        o.println("</" + tokenName + ">");
      }
    }
  }

  /// Print a string, expanding special XML characters
  public static void printXMLstring(PrintStream o, String s) {
    for ( int i = 0 ; i < s.length() ; i++ ) {
      char c = s.charAt(i);
      switch (c) {
      case '<': o.print("&lt;"); break;
      case '>': o.print("&gt;"); break;
      case '&': o.print("&amp;"); break;
      case '"': o.print("&quot;"); break;
      case '\'': o.print("&apos;"); break;
      default: o.print(c);
      }
    }
  }
}
