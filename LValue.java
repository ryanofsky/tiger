import Semant.Type;
import Interp.Operand;

public class LValue 
{
  public Operand operand;
  public Type type;
  
  public LValue(Type type, Operand operand)
  {
    this.type = type;
    this.operand = operand;
  }
}
