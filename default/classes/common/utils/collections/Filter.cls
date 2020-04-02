/**
 * A pipeable Operation that filters a Collection based on some criterion.
 */
public abstract class Filter extends CollectionPipe.Operation {

    /*
     * Convenience methods for combining and manipulating Filters
     */

    public static InvertFilter invert(Filter filter) {
        return new InvertFilter(filter);
    }

    public static OrCombinator any(
            Filter filter1,
            Filter filter2) {
        return new OrCombinator(
                new List<Filter> {filter1, filter2});
    }

    public static OrCombinator any(
            Filter filter1,
            Filter filter2,
            Filter filter3) {
        return new OrCombinator(
                new List<Filter> {filter1, filter2, filter3});
    }

    public static OrCombinator any(
            Filter filter1,
            Filter filter2,
            Filter filter3,
            Filter filter4) {
        return new OrCombinator(
                new List<Filter> {filter1, filter2, filter3, filter4});
    }

    public static AndCombinator all(
            Filter filter1,
            Filter filter2) {
        return new AndCombinator(
                new List<Filter> {filter1, filter2});
    }

    public static AndCombinator all(
            Filter filter1,
            Filter filter2,
            Filter filter3) {
        return new AndCombinator(
                new List<Filter> {filter1, filter2, filter3});
    }

    public static AndCombinator all(
            Filter filter1,
            Filter filter2,
            Filter filter3,
            Filter filter4) {
        return new AndCombinator(
                new List<Filter> {filter1, filter2, filter3, filter4});
    }

    /**
     * Filter that allows elements that DO NOT match the given filter.
     */
    public class InvertFilter extends Filter {

        private Filter filter;

        public InvertFilter(Filter filter) {
            this.filter = filter;
        }

        protected override boolean isAllowed(Object obj) {
            return !filter.isAllowed(obj);
        }

    }

    /**
     * Filter that allows elements that match AT LEAST ONE of the given filters.
     */
    public class OrCombinator extends Filter {

        private List<Filter> filters = new List<Filter>();

        public OrCombinator(List<Filter> filters) {
            this.filters = filters;
        }

        protected override boolean isAllowed(Object obj) {
            for (Filter filter : filters) {
                if (filter.isAllowed(obj)) {
                    return true;
                }
            }
            return false;
        }

    }

    /**
     * Filter that allows elements that match ALL of the given filters.
     */
    public class AndCombinator extends Filter {

        private List<Filter> filters = new List<Filter>();

        public AndCombinator(List<Filter> filters) {
            this.filters = filters;
        }

        protected override boolean isAllowed(Object obj) {
            for (Filter filter : filters) {
                if (!filter.isAllowed(obj)) {
                    return false;
                }
            }
            return true;
        }

    }

    ////////////////////////////////////////////////////////////////////////////
    // Filter class
    ////////////////////////////////////////////////////////////////////////////

    public override List<Object> process(List<Object> objs) {
        List<Object> newObjs = new List<Object>();
        for (Object obj : objs) {
            if (isAllowed(obj)) {
                newObjs.add(obj);
            }
        }
        return newObjs;
    }

    @TestVisible
    protected abstract boolean isAllowed(Object obj);

}
