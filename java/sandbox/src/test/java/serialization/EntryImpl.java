package serialization;

public class EntryImpl implements Entry {
    private String data;
    private int num;

    public EntryImpl() {
        // no-arg
    }

    public EntryImpl(String data, int num) {
        this.data = data;
        this.num = num;
    }

    public String getData() {
        return this.data;
    }

    public void setData(String data) {
        this.data = data;
    }

    public int getNum() {
        return this.num;
    }

    public void setNum(int num) {
        this.num = num;
    }
}
