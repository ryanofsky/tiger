package Interp;

/// Execution environment: stack values, etc.
public class Environment {

    // Topmost activation record
    public Activation stack;

    public Environment() {
	stack = new Activation(null, null, null);
    }
}
