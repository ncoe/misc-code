package arrays;

import org.junit.Assert;
import org.junit.Test;

/**
 * Investigating some properties about array implementations in java.
 * Created by Nathan R Coe on 1/28/2015.
 */
public class ArrayTest {
    @Test
    public void primitiveArrayChecks1() {
        byte[] ba = new byte[0];
        Assert.assertEquals("List of byte", checkType1(ba));

        char[] ca = new char[0];
        Assert.assertEquals("List of char", checkType1(ca));
    }

    private String checkType1(Object val) {
        if (null == val) {
            return "null";
        }

        // Operator '==' cannot be applied to 'java.lang.Class<capture<? extends java.lang.Object>>', 'java.lang.Class<byte[]>'
        // I am unable to silence this 'error' in intellij, but java does not see anything wrong with it.
        if (val.getClass() == byte[].class) {
            return "List of byte";
        }
        // 'equals()' between objects of inconvertible types 'Class<char[]>' and 'Class<? extends Object>'
        //noinspection EqualsBetweenInconvertibleTypes
        if (val.getClass().equals(char[].class)) {
            return "List of char";
        }

        return val.getClass().toString();
    }

    @Test
    public void primitiveArrayChecks2() {
        byte[] ba = new byte[0];
        Assert.assertEquals("List of byte", checkType2(ba));

        char[] ca = new char[0];
        Assert.assertEquals("List of char", checkType2(ca));
    }

    private String checkType2(Object val) {
        if (null == val) {
            return "null";
        }

        // Primitive arrays cannot be extended
        if (val instanceof char[]) {
            return "List of char";
        }

        if (val instanceof byte[]) {
            return "List of byte";
        }

        return val.getClass().toString();
    }

    @Test
    public void primitiveArrayChecks3() {
        byte[] ba = new byte[0];
        Assert.assertEquals("List of byte", checkType3(ba));

        char[] ca = new char[0];
        Assert.assertEquals("List of char", checkType3(ca));
    }

    private String checkType3(Object val) {
        if (null == val) {
            return "null";
        }

        Class<?> clazz = val.getClass();
        if (clazz.isArray()) {
            Class<?> type = clazz.getComponentType();

            if (type.isPrimitive()) {
                if (byte.class == type) {
                    return "List of byte";
                }

                if (char.class == type) {
                    return "List of char";
                }
            }

            return "List of " + type.toString();
        }

        return val.getClass().toString();
    }
}
