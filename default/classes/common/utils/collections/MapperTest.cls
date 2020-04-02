@isTest
public class MapperTest {

    /**
     * A simple Mapper that multiplies Integers by some constant.
     */
    private class Multiplier extends Mapper {

        private Integer multiplier;

        public Multiplier(Integer multiplier) {
            this.multiplier = multiplier;
        }

        protected override Object apply(Object obj) {
            return ((Integer) obj) * multiplier;
        }

    }

    @isTest
    private static void testMapping() {
        // GIVEN a Mapper
        Mapper mapper = new Multiplier(2);

        // WHEN it is used to modify a list
        List<Object> results = mapper.process(new List<Integer> { 2, 4, 6 });

        // THEN the resulting List has been modified
        System.assertEquals(3, results.size());
        System.assertEquals(4, results[0]);
        System.assertEquals(8, results[1]);
        System.assertEquals(12, results[2]);
    }

    @isTest
    private static void testMapCombinator() {
        // GIVEN a MapCombinator wrapping some Mappers
        Mapper.MapCombinator mapper = Mapper.combine(
            new Multiplier(2),
            new Multiplier(4));

        // WHEN it is used to filter a List
        List<Object> results = mapper.process(new List<Integer> { 2, 4, 6 });

        // THEN all of the wrapped Mappers are applied
        System.assertEquals(3, results.size());
        System.assertEquals(16, results[0]);
        System.assertEquals(32, results[1]);
        System.assertEquals(48, results[2]);
    }

}
