#JAVAC_OPTIONS = -classpath /u/4/c/cs4115/antlr:.
JAVAC_OPTIONS = -classpath ../antlr/:./


#TEST_CASES = error1.tig error2.tig error3.tig error4.tig error5.tig error6.tig error7.tig error8.tig error9.tig error10.tig error11.tig error12.tig error13.tig error14.tig error15.tig error16.tig error17.tig error18.tig error19.tig error20.tig error21.tig error22.tig error23.tig error24.tig error25.tig error26.tig error27.tig error28.tig error29.tig error30.tig error31.tig error32.tig error33.tig error34.tig error35.tig error36.tig error37.tig error26a.tig

#TEST_CASES = test.tig

TEST_CASES = array_1.tig   exprifthen.tig             funcMutualRec.tig          print-simple.tig array_2types.tig           exprifthenelse.tig         funcParameters.tig         print.tig array_comp.tig             exprnestifthenelse.tig     funcProcSimple.tig         printi.tig array_ofArr.tig            exprnestifthenelse2.tig    funcRecursive.tig          record_1.tig array_record.tig           exprnestwhile.tig          funcRedefined.tig          record_array.tig binop_1.tig                exprwhile.tig              funcSimple.tig             record_nil.tig binop_lazy.tig             exprwhile2.tig             getchar.tig                record_ofRec.tig binop_lazy1.tig            funcForwardDecl.tig        let_inner.tig              size.tig chr.tig                    funcGlobal.tig             let_outer.tig              string_1.tig concat.tig                 funcGlobalLocal.tig        not.tig                    string_comp.tig exprfor.tig                funcGlobalLocalFunc.tig    ord.tig                    substring.tig exprfor2.tig               funcLocal.tig              print-add.tig



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
	-java $(JAVAC_OPTIONS) TC ./tests/$@





