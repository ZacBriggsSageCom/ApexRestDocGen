/**
 * Validation rule for determining whether a ContentDocument is linked to a
 * record other than a User.
 */
public class IsContentDocumentLinkedToRecordRule implements ValidationRule {
    
    private String contentDocumentId; 

    public IsContentDocumentLinkedToRecordRule(String contentDocumentId) {
        this.contentDocumentId = contentDocumentId;
    }

    public Boolean isValid() {
        try {
            return !FileUtils.getLinkedNonUserEntityIds(contentDocumentId).isEmpty();
        } catch (Exception e) {
            return false;
        }
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(
                HttpUtils.STATUS_BAD_REQUEST, Label.File_Not_Linked, '');
    }
}
