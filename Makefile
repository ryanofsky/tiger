#JAVAC_OPTIONS = -classpath /u/4/c/cs4115/antlr:.
#JAVAC_OPTIONS = -classpath ../antlr:./ antlr/Tool
JAVAC_OPTIONS =

TEST_CASES = merge.tig queens.tig test1.tig test2.tig test3.tig test4.tig test5.tig test6.tig test7.tig test8.tig test9.tig test10.tig test11.tig test12.tig test13.tig test14.tig test15.tig test16.tig test17.tig test18.tig test19.tig test20.tig test21.tig test22.tig test23.tig test24.tig test25.tig test26.tig test27.tig test28.tig test29.tig test30.tig test31.tig test32.tig test33.tig test34.tig test35.tig test36.tig test37.tig test38.tig test39.tig test40.tig test41.tig test42.tig test43.tig test44.tig test45.tig test46.tig test47.tig test48.tig test49.tig

CHECK_IN = TigerSemant.g
CHECK_JAVA = TigerSemant.java TigerSemantTokenTypes.java
CHECK_CLASSES = TigerSemant.class
CHECK_CRUFT = TigerSemantTokenTypes.txt

COMPILER_JAVA = TC.java TigerParserTokenTypes.java TigerSemantTokenTypes.java
COMPILER_CLASSES = TC.class TigerParserTokenTypes.class TigerSemantTokenTypes.class

all : check compiler

check : $(CHECK_CLASSES)
compiler : $(COMPILER_CLASSES)

$(CHECK_JAVA) $(CHECK_CRUFT): $(CHECK_IN)
	java antlr.Tool $(CHECK_IN)

$(CHECK_CLASSES) : $(CHECK_JAVA)
	javac $(JAVAC_OPTIONS) $(CHECK_JAVA)

$(COMPILER_CLASSES) : $(COMPILER_JAVA)
	javac $(JAVAC_OPTIONS) $(COMPILER_JAVA)

clean :
	rm -f $(CHECK_JAVA) $(CHECK_CRUFT) $(CHECK_CLASSES) $(COMPILER_CLASSES)

test : $(TEST_CASES)

$(TEST_CASES) : all
	java TC ./tests/$@