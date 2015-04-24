package serialization;

import org.codehaus.jackson.map.ObjectMapper;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import java.io.IOException;

public class SerializationTest {
    private ObjectMapper mapper;

    @Before
    public void setup() {
        mapper = new ObjectMapper();
    }

    @Test
    public void deserialize() throws IOException {
        MapHack theMap = new MapHack();
        theMap.put("alpha", new EntryImpl("bravo", 12));

        byte[] encoded = mapper.writeValueAsBytes(theMap);

        MapHack decoded = mapper.readValue(encoded, MapHack.class);

//        JsonNode encoded = mapper.valueToTree(theMap);
//
//        MapHack decoded = mapper.treeToValue(encoded, MapHack.class);

        Assert.assertTrue(decoded.containsKey("alpha"));
    }
}
