/**
 * Filter that compares elements to some value using the equals operator.
 */
public class EqualsFilter extends Filter {

    private Object value;

    public EqualsFilter(Object value) {
        this.value = value;
    }

    protected override boolean isAllowed(Object obj) {
        return obj == value;
    }

}
