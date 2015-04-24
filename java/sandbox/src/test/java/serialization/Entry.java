package serialization;

import org.codehaus.jackson.annotate.JsonTypeInfo;
import org.codehaus.jackson.map.annotate.JsonTypeIdResolver;

//@JsonTypeInfo(use = JsonTypeInfo.Id.CUSTOM)
//@JsonTypeIdResolver(EntryTypeIdResolver.class)
public interface Entry {
    String getData();
    void setData(String data);

    int getNum();
    void setNum(int num);
}
