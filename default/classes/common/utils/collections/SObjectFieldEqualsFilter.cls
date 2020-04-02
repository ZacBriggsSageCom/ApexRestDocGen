/**
 * Filter that compares some field of an SObject to some value using the equals
 * operator.
 */
public class SObjectFieldEqualsFilter extends Filter {

    private String fieldName;

    private Object value;

    public SObjectFieldEqualsFilter(String fieldName, Object value) {
        this.fieldName = fieldName;
        this.value = value;
    }

    protected override boolean isAllowed(Object obj) {
        SObject sObj = (SObject) obj;
        return sObj.get(fieldName) == value;
    }

}
