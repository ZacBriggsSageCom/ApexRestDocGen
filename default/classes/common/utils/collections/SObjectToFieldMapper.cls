/**
 * Mapper that transforms an SObject into one of its fields.
 *
 * This supports relationship fields only for custom relationships, that is,
 * those ending with '__r'.
 */
public class SObjectToFieldMapper extends Mapper {

    private String fieldName;

    public SObjectToFieldMapper(String fieldName) {
        this.fieldName = fieldName;
    }

    protected override Object apply(Object obj) {
        SObject sObj = (SObject) obj;
        if (fieldName.endsWith('__r')) {
            return sObj.getSObject(fieldName);
        } else {
            return sObj.get(fieldName);
        }
    }

}
