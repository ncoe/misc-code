package com.github.ncoe.typecons;

import com.github.ncoe.typecons.exception.NotImplementedException;
import org.junit.Assert;
import org.junit.Test;

public class AutoImplementTest {
    @Test
    public void blackHoleTestEmpty() {
        ITest test = AutoImplement.blackHole(ITest.class);
        Assert.assertNotEquals(ITest.class, test.getClass());

        Assert.assertNull(test.getString());
        Assert.assertSame(0, test.getInteger());
    }

    @Test
    public void blackHoleTestPartial() {
        ITest test = AutoImplement.blackHole(Partial.class);
        Assert.assertNotEquals(ITest.class, test.getClass());
        Assert.assertNotEquals(Partial.class, test.getClass());

        Assert.assertEquals("Hello World", test.getString());
        Assert.assertSame(0, test.getInteger());
    }

    @Test
    public void blackHoleTestFull() {
        ITest test = AutoImplement.blackHole(Full.class);
        Assert.assertSame(Full.class, test.getClass());

        Assert.assertEquals("Hello World", test.getString());
        Assert.assertSame(42, test.getInteger());
    }

    @Test(expected = NotImplementedException.class)
    public void whiteHoleTestEmptyString() {
        ITest test = AutoImplement.whiteHole(ITest.class);
        Assert.assertNotEquals(ITest.class, test.getClass());

        test.getString();
    }

    @Test(expected = NotImplementedException.class)
    public void whiteHoleTestEmptyInteger() {
        ITest test = AutoImplement.whiteHole(ITest.class);
        Assert.assertNotEquals(ITest.class, test.getClass());

        test.getInteger();
    }

    @Test
    public void whiteHoleTestPartialString() {
        ITest test = AutoImplement.whiteHole(Partial.class);
        Assert.assertNotEquals(ITest.class, test.getClass());
        Assert.assertNotEquals(Partial.class, test.getClass());

        Assert.assertEquals("Hello World", test.getString());
    }

    @Test(expected = NotImplementedException.class)
    public void whiteHoleTestPartialInteger() {
        ITest test = AutoImplement.whiteHole(Partial.class);
        Assert.assertNotEquals(ITest.class, test.getClass());
        Assert.assertNotEquals(Partial.class, test.getClass());

        test.getInteger();
    }

    @Test
    public void whiteHoleTestFullString() {
        ITest test = AutoImplement.whiteHole(Full.class);
        Assert.assertSame(Full.class, test.getClass());

        Assert.assertEquals("Hello World", test.getString());
    }

    @Test
    public void whiteHoleTestFullInteger() {
        ITest test = AutoImplement.whiteHole(Full.class);
        Assert.assertSame(Full.class, test.getClass());

        Assert.assertSame(42, test.getInteger());
    }
}
