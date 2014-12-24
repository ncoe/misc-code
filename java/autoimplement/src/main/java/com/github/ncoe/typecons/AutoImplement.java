package com.github.ncoe.typecons;

import com.github.ncoe.typecons.exception.ConstructionException;
import com.github.ncoe.typecons.exception.NotImplementedException;
import javassist.util.proxy.MethodFilter;
import javassist.util.proxy.MethodHandler;
import javassist.util.proxy.ProxyFactory;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

/**
 * A utility for auto-implementing the rest of an abstract class or interface.
 */
public final class AutoImplement {
    private AutoImplement() {
        super();
    }

    /**
     * Creates a new instance of the class specified by the provided base class.
     * If the class is not abstract, it must provide a no-arg constructor in order to create the instance.
     * If the class is abstract, unimplemented methods will be implemented to return the default value for the return type when invoked.
     * The default value for a floating point number is NaN.
     *
     * @param base The class to create an instance of.
     * @param <T> The class to create a no-arg constructed instance of, or an auto-implemented instance of.
     * @return A no-arg constructed instance of the base class for non-abstract classes.
     * A auto-implemented class that returns a default initialized value appropriate to the return type when an auto-implemented method is called.
     */
    public static <T> T blackHole(Class<T> base) {
        if (!Modifier.isAbstract(base.getModifiers())) {
            return newInstance(base);
        }

        MethodHandler mh = new MethodHandler() {
            @Override
            public Object invoke(Object self, Method m, Method proceed, Object[] args) throws Throwable {
                assert null == proceed;

                Class<?> returnType = m.getReturnType();
                if (!returnType.isPrimitive()) {
                    return returnType.cast(null);
                } else if (returnType.equals(byte.class) || returnType.equals(short.class) || returnType.equals(int.class) || returnType.equals(long.class)) {
                    return 0;
                } else if (returnType.equals(float.class)) {
                    return Float.NaN;
                } else if (returnType.equals(double.class)) {
                    return Double.NaN;
                } else if (returnType.equals(boolean.class)) {
                    return false;
                } else if (returnType.equals(char.class)) {
                    return '\u0000';
                }

                // Added just in case a primitive has been overlooked.
                throw new NotImplementedException("The default value for a(n) " + returnType.getName() + " has not been determined.");
            }
        };

        return autoImplement(base, mh);
    }

    /**
     * Creates a new instance of the class specified by the provided base class.
     * If the class is not abstract, it must provide a no-arg constructor in order to create the instance.
     * if the class is abstract, unimplemented methods will be implemented to throw a NotImplementedException when invoked.
     *
     * @param base The class to create an instance of.
     * @param <T> The class to create a no-arg constructed instance of, or an auto-implemented instance of.
     * @return A no-arg constructed instance of the base class for non-abstract classes.
     * A auto-implemented class that throws a NotImplementedException when an auto-implemented method is called.
     */
    public static <T> T whiteHole(Class<T> base) {
        if (!Modifier.isAbstract(base.getModifiers())) {
            return newInstance(base);
        }

        MethodHandler mh = new MethodHandler() {
            @Override
            public Object invoke(Object self, Method m, Method proceed, Object[] args) throws Throwable {
                assert null == proceed;
                throw new NotImplementedException(m.getName() + " has not been implemented.");
            }
        };

        return autoImplement(base, mh);
    }

    /**
     * Creates a new instance of the class specified by the base parameter.
     * The base class must have a no-arg constructor. The construction may fail if trying to access the no-arg constructor
     * would violate java's security policies.
     *
     * @param base The class to create a new instance of.
     * @param <T> The type of class to create a new instance of.
     * @return A default constructed instance of the specified class.
     */
    private static <T> T newInstance(Class<T> base) {
        try {
            Constructor<T> dc = base.getDeclaredConstructor();
            dc.setAccessible(true);
            return dc.newInstance();
        } catch (Exception e) {
            throw new ConstructionException(base.getName() + " does not have a no-arg constructor.", e);
        }
    }

    /**
     * @param base The base class to create and auto-implementation of.
     * @param mh The strategy to use whn invoking an abstract method.
     * @param <T> The type of class to create an auto-implementation of.
     * @return A class that implements base, using the provided method handler for any method that has not been implemented.
     */
    @SuppressWarnings("unchecked")
    private static <T> T autoImplement(Class<T> base, MethodHandler mh) {
        ProxyFactory pf = new ProxyFactory();

        // Choose how the implementation should take place. If an interface is provided, the created class will implement
        // that interface. If an abstract class is provided, the created class will extend it.
        if (Modifier.isInterface(base.getModifiers())) {
            pf.setInterfaces(new Class[]{base});
        } else {
            pf.setSuperclass(base);
        }

        // The created class should not try to intercept a method that already has an implementation.
        MethodFilter mf = new MethodFilter() {
            @Override
            public boolean isHandled(Method method) {
                return Modifier.isAbstract(method.getModifiers());
            }
        };
        pf.setFilter(mf);

        // Try to create an class that extends or implemented the base class.
        T t;
        try {
            // Is there a way to check this so that warnings are not suppressed?
            t = (T) pf.create(new Class[0], new Object[0], mh);
        } catch (NoSuchMethodException e) {
            throw new ConstructionException("Failed to create a new proxy", e);
        } catch (InstantiationException e) {
            throw new ConstructionException("Failed to create a new proxy", e);
        } catch (IllegalAccessException e) {
            throw new ConstructionException("Failed to create a new proxy", e);
        } catch (InvocationTargetException e) {
            throw new ConstructionException("Failed to create a new proxy", e);
        }

        // Return the auto implemented class.
        return t;
    }
}
