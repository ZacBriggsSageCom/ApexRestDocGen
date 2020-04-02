/**
 * Validation rule for determining whether a ContentDocument exists, i.e. where
 * the failure condition is that it does not exist.
 */
public class DoesContentDocumentExistRule extends DoesRecordExistRule {

    public DoesContentDocumentExistRule(String contentDocumentId) {
        super(contentDocumentId, Label.File_Does_Not_Exist);
    }
}
