package Interp;

public class LabelOperand extends Operand {
    Label target;

    public LabelOperand(Label t) { target = t; }

    public String string() { return target.value(); }

    public Label value() { return target; }
}
