@isTest
public class FilterTest {

    /**
     * A simple Filter that allows only Strings beginning with some prefix.
     */
    private class PrefixFilter extends Filter {

        private String prefix;

        public PrefixFilter(String prefix) {
            this.prefix = prefix;
        }

        protected override boolean isAllowed(Object obj) {
            return obj instanceof String &&
                    ((String) obj).startsWith(prefix);
        }

    }

    /**
     * A simple Filter that allows only Strings ending with some prefix.
     */
    private class SuffixFilter extends Filter {

        private String suffix;

        public SuffixFilter(String suffix) {
            this.suffix = suffix;
        }

        protected override boolean isAllowed(Object obj) {
            return obj instanceof String &&
                    ((String) obj).endsWith(suffix);
        }

    }

    @isTest
    private static void testFiltering() {
        // GIVEN a Filter
        Filter filter = new PrefixFilter('a');

        // WHEN it is used to filter a List
        List<Object> results = filter.process(
                new List<String> { 'apple', 'banana', 'avocado' });

        // THEN the resulting List has been filtered
        System.assertEquals(2, results.size());
        System.assertEquals('apple', results[0]);
        System.assertEquals('avocado', results[1]);
    }

    @isTest
    private static void testInvertFilter() {
        // GIVEN an InvertFilter wrapping some filter
        Filter.InvertFilter filter = Filter.invert(new PrefixFilter('a'));

        // WHEN it is used to filter a List
        List<Object> results = filter.process(
                new List<String> { 'apple', 'banana', 'avocado' });

        // THEN the wrapped filter has been inverted
        System.assertEquals(1, results.size());
        System.assertEquals('banana', results[0]);
    }

    @isTest
    private static void testOrCombinator() {
        // GIVEN an OrCombinator wrapping some Filters
        Filter.OrCombinator filter = Filter.any(
            new PrefixFilter('a'),
            new PrefixFilter('b'));

        // WHEN it is used to filter a List
        List<Object> results = filter.process(
                new List<String> { 'apple', 'banana', 'cookie', 'avocado' });

        // THEN all of the wrapped Filters are applied
        System.assertEquals(3, results.size());
        System.assertEquals('apple', results[0]);
        System.assertEquals('banana', results[1]);
        System.assertEquals('avocado', results[2]);
    }

    @isTest
    private static void testAndCombinator() {
        // GIVEN an AndCombinator wrapping some Filters
        Filter.AndCombinator filter = Filter.all(
            new PrefixFilter('a'),
            new SuffixFilter('e'));

        // WHEN it is used to filter a List
        List<Object> results = filter.process(
                new List<String> { 'apple', 'banana', 'avocado' });

        // THEN all of the wrapped Filters are applied
        System.assertEquals(1, results.size());
        System.assertEquals('apple', results[0]);
    }

}
