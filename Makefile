TEST_CASES = merge queens test1 test10 test11 test12 test13 test14 test15 test16 test17 test18 test19 test2 test20 test21 test22 test23 test24 test25 test26 test27 test28 test29 test3 test30 test31 test32 test33 test34 test35 test36 test37 test38 test39 test4 test40 test41 test42 test43 test44 test45 test46 test47 test48 test49 test5 test6 test7 test8 test9

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
clean : testclean
	rm -f $(ANTLR_JAVA) $(ANTLR_CRUFT) $(ANTLR_CLASSES) $(AST_JAVA) $(AST_CRUFT) $(AST_CLASSES) $(MISC_CLASSES)

test : $(TEST_CASES)
	
$(TEST_CASES) : all
	java Tig2xml ./test_in/$@.tig > ./test_out/$@.xml

testclean :
	rm ./test_out/*.xml

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

