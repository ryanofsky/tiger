package Interp;

// Unconditional branch
public class Jmp extends Statement {
    LabelOperand target;

    public Jmp(LabelOperand t) { target = t; }

    public String string() {
	return "  jmp " + target.string();
    }

    public Statement execute(Environment e) {
	return target.value();
    }
}
