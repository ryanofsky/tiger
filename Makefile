#JAVAC_OPTIONS = -classpath /u/4/c/cs4115/antlr:.
JAVAC_OPTIONS = -classpath ../antlr/:./
#JAVAC_OPTIONS =

TEST_CASES = array_1   exprifthen             funcMutualRec          print-simple array_2types           exprifthenelse         funcParameters         print array_comp             exprnestifthenelse     funcProcSimple         printi array_ofArr            exprnestifthenelse2    funcRecursive          record_1           exprnestwhile          funcRedefined          record_array binop_1                exprwhile              funcSimple              binop_lazy             exprwhile2             getchar                record_ofRec binop_lazy1            funcForwardDecl        let_inner              size chr                    funcGlobal             let_outer              string_1 concat                 funcGlobalLocal        not                    string_comp exprfor                funcGlobalLocalFunc    ord                    substring exprfor2               funcLocal              print-add array_record record_nil



SEMANT_IN = TigerTranslate.g
SEMANT_JAVA = TigerTranslate.java TigerTranslateTokenTypes.java
SEMANT_CLASSES = TigerTranslate.class TigerTranslateTokenTypes.class
SEMANT_CRUFT = TigerTranslateTokenTypes.txt

COMPILER_JAVA = TC.java TigerParserTokenTypes.java TigerTokenTypes.java LValue.java
COMPILER_CLASSES = TC.class TigerParserTokenTypes.class TigerTokenTypes.class LValue.class

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
	java $(JAVA_OPTIONS) TC ./tests/$@.tig > ./tests_mips/$@.mips
	perl tester.pl ./tests_mips/$@.mips > ./tests_out/$@.out
#	diff -wb ./tests_out/$@.out ./tests_canon/$@.out

	cat ./tests_out/$@.out
	cat ./tests_canon/$@.out


testclean :
	-rm ./tests_out/*.xml


