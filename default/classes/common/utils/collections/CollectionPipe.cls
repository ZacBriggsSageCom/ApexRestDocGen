/**
 * Pipe that can be used to apply operations to a Collection in sequence.
 *
 * Unfortunately this is only really useful with Lists due to limitations of
 * Apex (Sets cannot be cast).
 */
public class CollectionPipe {

    public abstract class Operation {
        public abstract List<Object> process(List<Object> objs);
    }

    private List<Object> objs;

    public CollectionPipe(List<Object> objs) {
        this.objs = objs;
    }

    public CollectionPipe(Set<Object> objs) {
        this.objs = new List<Object>(objs);
    }

    public CollectionPipe apply(Operation op) {
        objs = op.process(objs);
        return this;
    }

    public List<Object> toList() {
        return objs;
    }

    public Set<Object> toSet() {
        return new Set<Object>(objs);
    }

}
