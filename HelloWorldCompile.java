import Interp.*;

class HelloWorldCompile {

    public static void main(String args[]) {

	Label l = new Label("print");
	Statement printFunc = l;
	printFunc
	    .append(new Ent())
	    .append(new Sys(Sys.PRINT))
	    .append(new Rts());

	Statement s = new Label("main");
	s.append(new Ent())
	 .append(new Psh(1))
	 .append(new Mov(new FrameRel(0), new StringConstant("Hello world\n")))
	 .append(new Jsr(new LabelOperand(l), 0) )
	 .append(new Mov(new FrameRel(0), new StringConstant("This works\n")))
	 .append(new Jsr(new LabelOperand(l), 1) )
         .append(new Rts());

        s.printMips();	

	l.printMips();
    }

}
