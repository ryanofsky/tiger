package Semant;

import java.lang.String;

public class RECORD extends Type {
   public String fieldName;
   public Type fieldType;
   public RECORD tail;
   public RECORD(String n, Type t, RECORD x) {
       fieldName=n; fieldType=t; tail=x;
   }
   public boolean coerceTo(Type t) {
       return this==t.actual();
   }
}
   

