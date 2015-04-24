package serialization;

import java.util.Comparator;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

/**
 * The implementation is used here, because the following exception is returned otherwise:<br/>
 * org.codehaus.jackson.map.JsonMappingException: Can not construct instance of serialization.Entry, problem: abstract types can only be instantiated with additional type information
 */
public class MapHack extends TreeMap<String, EntryImpl> {
    public MapHack() {
        super();
    }

    public MapHack(Comparator<? super String> comparator) {
        super(comparator);
    }

    public MapHack(Map<? extends String, ? extends EntryImpl> m) {
        super(m);
    }

    public MapHack(SortedMap<String, ? extends EntryImpl> m) {
        super(m);
    }

    @Override
    public MapHack clone() {
        return (MapHack) super.clone();
    }
}
