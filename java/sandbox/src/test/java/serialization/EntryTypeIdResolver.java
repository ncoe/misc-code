package serialization;

import org.codehaus.jackson.annotate.JsonTypeInfo.Id;
import org.codehaus.jackson.map.jsontype.TypeIdResolver;
import org.codehaus.jackson.map.type.TypeFactory;
import org.codehaus.jackson.map.util.ClassUtil;
import org.codehaus.jackson.type.JavaType;

/**
 * See <a href="https://www.thomaskeller.biz/blog/2013/09/10/custom-polymorphic-type-handling-with-jackson/">custom polymorphic type handling with jackson</a>
 */
public class EntryTypeIdResolver implements TypeIdResolver {
    private JavaType mBaseType;

    public void init(JavaType javaType) {
        this.mBaseType = javaType;
    }

    public String idFromValue(Object o) {
        return EntryImpl.class.getName();
    }

    public String idFromValueAndType(Object o, Class<?> aClass) {
        return EntryImpl.class.getName();
    }

    public JavaType typeFromId(String type) {
        Class<?> clazz;
        try {
            clazz = ClassUtil.findClass(type);
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException("Cannot find the class: " + type);
        }
        return TypeFactory.defaultInstance().constructSpecializedType(mBaseType, clazz);
    }

    public Id getMechanism() {
        return Id.CUSTOM;
    }
}
