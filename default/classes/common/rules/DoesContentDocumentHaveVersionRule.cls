/**
 * Validation rule for determining whether a ContentDocument has at least one
 * ContentVersion.
 */
public class DoesContentDocumentHaveVersionRule implements ValidationRule {

    private String contentDocumentId;
    
    public DoesContentDocumentHaveVersionRule(String contentDocumentId) {
        this.contentDocumentId = contentDocumentId;
    }

    public Boolean isValid() {
        return contentDocumentId != null
                && SObjectUtils.isValidId(contentDocumentId)
                && !FileRepository.getContentVersionsByContentDocumentIds(
                        new Set<Id>{contentDocumentId}).isEmpty();
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(
                HttpUtils.STATUS_INTERNAL_SERVER_ERROR,
                Label.Error_Retrieving_File,
                ''
        );
    }
}
