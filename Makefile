#JAVAC_OPTIONS = -classpath /u/4/c/cs4115/antlr:.
#JAVAC_OPTIONS = -classpath ../antlr:./ antlr/Tool
JAVAC_OPTIONS =

TEST_CASES = merge.tig queens.tig test1.tig test2.tig test3.tig test4.tig test5.tig test6.tig test7.tig test8.tig test9.tig test10.tig test11.tig test12.tig test13.tig test14.tig test15.tig test16.tig test17.tig test18.tig test19.tig test20.tig test21.tig test22.tig test23.tig test24.tig test25.tig test26.tig test27.tig test28.tig test29.tig test30.tig test31.tig test32.tig test33.tig test34.tig test35.tig test36.tig test37.tig test38.tig test39.tig test40.tig test41.tig test42.tig test43.tig test44.tig test45.tig test46.tig test47.tig test48.tig test49.tig

SEMANT_IN = TigerSemant.g
SEMANT_JAVA = TigerSemant.java TigerSemantTokenTypes.java
SEMANT_CLASSES = TigerSemant.class TigerSemantTokenTypes.class
SEMANT_CRUFT = TigerSemantTokenTypes.txt

COMPILER_JAVA = TC.java TigerParserTokenTypes.java
COMPILER_CLASSES = TC.class TigerParserTokenTypes.class

all : semant compiler

semant : $(SEMANT_CLASSES)
compiler : $(COMPILER_CLASSES)

$(SEMANT_JAVA) $(SEMANT_CRUFT): $(SEMANT_IN)
	java antlr.Tool $(SEMANT_IN)

$(SEMANT_CLASSES) : $(SEMANT_JAVA)
	javac $(JAVAC_OPTIONS) $(SEMANT_JAVA)

$(COMPILER_CLASSES) : $(COMPILER_JAVA)
	javac $(JAVAC_OPTIONS) $(COMPILER_JAVA)

clean :
	rm -f $(SEMANT_JAVA) $(SEMANT_CRUFT) $(SEMANT_CLASSES) $(COMPILER_CLASSES)

test : $(TEST_CASES)

$(TEST_CASES) : all
	java TC ./tests/$@
