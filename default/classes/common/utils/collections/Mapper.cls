/**
 * A pipeable Operation that transform each element of a Collection.
 */
public abstract class Mapper extends CollectionPipe.Operation {

    /*
     * Convenience methods for combining Mappers
     */

    public static MapCombinator combine(
            Mapper mapper1,
            Mapper mapper2) {
        return new MapCombinator(
                new List<Mapper> {mapper1, mapper2});
    }

    public static MapCombinator combine(
            Mapper mapper1,
            Mapper mapper2,
            Mapper mapper3) {
        return new MapCombinator(
                new List<Mapper> {mapper1, mapper2, mapper3});
    }

    public static MapCombinator combine(
            Mapper mapper1,
            Mapper mapper2,
            Mapper mapper3,
            Mapper mapper4) {
        return new MapCombinator(
                new List<Mapper> {mapper1, mapper2, mapper3, mapper4});
    }

    /**
     * Mapper that applies multiple Mappers in a single iteration.
     */
    public class MapCombinator extends Mapper {

        private List<Mapper> mappers = new List<Mapper>();

        public MapCombinator(List<Mapper> mappers) {
            this.mappers = mappers;
        }

        protected override Object apply(Object obj) {
            Object newObj = obj;
            for (Mapper mapper : mappers) {
                newObj = mapper.apply(newObj);
            }
            return newObj;
        }

    }

    ////////////////////////////////////////////////////////////////////////////
    // Mapper class
    ////////////////////////////////////////////////////////////////////////////

    public override List<Object> process(List<Object> objs) {
        List<Object> newObjs = new List<Object>();
        for (Object obj : objs) {
            newObjs.add(apply(obj));
        }
        return newObjs;
    }

    @TestVisible
    protected abstract Object apply(Object obj);

}
