package Semant;

import java.lang.String;

public class NAME extends Type {
    public String name;
    private Type binding;

    public NAME(String n) { name=n; }

    /// Return true if this type is part of an unterminated loop
    public boolean isLoop() {
	Type b = binding; 
	boolean any;
	binding=null;
	if (b==null) any=true;
	else if (b instanceof NAME)
            any=((NAME)b).isLoop();
	else any=false;
	binding=b;
	return any;
    }

    public Type actual() { return binding.actual(); }

    public boolean coerceTo(Type t) {
	return this.actual().coerceTo(t);
    }

    /// Set the type actually bound to this one
    public void bind(Type t) { binding = t; }
}


