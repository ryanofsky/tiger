#JAVAC_OPTIONS = -classpath /u/4/c/cs4115/antlr:.
JAVAC_OPTIONS = -classpath ../antlr/:./

#TEST_CASES = merge.tig queens.tig test1.tig test2.tig test3.tig test4.tig test5.tig test6.tig test7.tig test8.tig test9.tig test10.tig test11.tig test12.tig test13.tig test14.tig test15.tig test16.tig test17.tig test18.tig test19.tig test20.tig test21.tig test22.tig test23.tig test24.tig test25.tig test26.tig test27.tig test28.tig test29.tig test30.tig test31.tig test32.tig test33.tig test34.tig test35.tig test36.tig test37.tig test38.tig test39.tig test40.tig test41.tig test42.tig test43.tig test44.tig test45.tig test46.tig test47.tig test48.tig test49.tig

TEST_CASES = error1.tig error2.tig error3.tig error4.tig error5.tig error6.tig error7.tig error8.tig error9.tig error10.tig error11.tig error12.tig error13.tig error14.tig error15.tig error16.tig error17.tig error18.tig error19.tig error20.tig error21.tig error22.tig error23.tig error24.tig error25.tig error26.tig error27.tig error28.tig error29.tig error30.tig error31.tig error32.tig error33.tig error34.tig error35.tig error36.tig error37.tig error26a.tig

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
	java $(JAVAC_OPTIONS) antlr.Tool $(SEMANT_IN)

$(SEMANT_CLASSES) : $(SEMANT_JAVA)
	javac $(JAVAC_OPTIONS) $(SEMANT_JAVA)

$(COMPILER_CLASSES) : $(COMPILER_JAVA)
	javac $(JAVAC_OPTIONS) $(COMPILER_JAVA)

clean :
	rm -f $(SEMANT_JAVA) $(SEMANT_CRUFT) $(SEMANT_CLASSES) $(COMPILER_CLASSES)

test : $(TEST_CASES)

$(TEST_CASES) : all
	-java $(JAVAC_OPTIONS) TC ./errors/$@
