ANTLR_IN = tiger.g
ANTLR_JAVA = TigerLexer.java TigerParserTokenTypes.java TigerParser.java
ANTLR_CLASSES = TigerLexer.class TigerParserTokenTypes.class TigerParser.class
ANTLR_CRUFT = TigerParserTokenTypes.txt

AST_IN = TigerASTGram.g
AST_JAVA = TigerASTGram.java TigerTokenTypes.java
AST_CLASSES = TigerASTGram.class TigerTokenTypes.class
AST_CRUFT = TigerTokenTypes.txt

MISC_JAVA = Tig2xml.java TigerTokenText.java
MISC_CLASSES = Tig2xml.class TigerTokenText.class

all : $(ANTLR_CLASSES) $(AST_CLASSES) $(MISC_CLASSES)
antlr : $(ANTLR_JAVA)
clean :
	rm -f $(ANTLR_JAVA) $(ANTLR_CRUFT) $(ANTLR_CLASSES) $(AST_JAVA) $(AST_CRUFT) $(AST_CLASSES) $(MISC_CLASSES)

$(ANTLR_JAVA) $(ANTLR_CRUFT): $(ANTLR_IN) $(AST_CRUFT)
	java antlr.Tool $(ANTLR_IN) 

$(ANTLR_CLASSES) : $(ANTLR_JAVA)
	javac $(ANTLR_JAVA)

$(AST_JAVA) $(AST_CRUFT): $(AST_IN)
	java antlr.Tool $(AST_IN) 

$(AST_CLASSES) : $(AST_JAVA)
	javac $(AST_JAVA)

$(MISC_CLASSES) : $(MISC_JAVA) $(ANTLR_CLASSES)
	javac $(MISC_JAVA)

