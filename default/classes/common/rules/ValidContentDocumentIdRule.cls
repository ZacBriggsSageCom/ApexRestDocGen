/**
 * Validation rule for determining whether a ContentDocument Id is valid.
 */
public class ValidContentDocumentIdRule extends ValidIdRule {

    private static final String CONTENT_DOCUMENT_TYPE = 'ContentDocument';
    
    public ValidContentDocumentIdRule(String contentDocumentId) {
        super(contentDocumentId, Label.ContentDocument_Id_Invalid);
    }

    public override boolean isValid() {
        return super.isValid() && SObjectUtils.isOfType(recordId, CONTENT_DOCUMENT_TYPE);
    }
}
