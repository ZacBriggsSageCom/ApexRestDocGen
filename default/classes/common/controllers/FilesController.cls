/**
 * Controller for File access.
 */
public class FilesController {

    /**
     * Gets the link for viewing a File with the given ContentDocumentId.
     */
    public static FileLinkResponseModel getFileLink(String contentDocumentId) {

        // Verify request is valid (excluding whether requestor is authorized)
        RequestValidator requestValidator = new RequestValidator()
                .addRule(new ValidContentDocumentIdRule(contentDocumentId))
                .addRule(new DoesContentDocumentExistRule(contentDocumentId))
                .addRule(new IsContentDocumentLinkedToRecordRule(contentDocumentId))
                .addRule(new DoesContentDocumentHaveVersionRule(contentDocumentId));
        if (!requestValidator.isValid()) {
            return new FileLinkResponseModel(requestValidator.getErrorModel());
        }

        Id destinationDocumentId = Id.valueOf(contentDocumentId);

        // User requires temporary authentication if not already allowed access
        if (!FileUtils.doesUserHaveAccessTo(contentDocumentId)) {

            /*
             * Determine whether the User should be allowed temporary access.
             *
             * In this context, we can assume that the File will be linked to
             * only one target record. This is because when a File is saved, it
             * is saved anew against the single requested record. If a File were
             * to be linked to multiple records, we could not authenticate
             * properly, as access to those records and their related Files may
             * have differing rules, and we cannot know which one is correct.
             */
            Set<Id> linkedRecordIds = FileUtils.getLinkedNonUserEntityIds(contentDocumentId);
            Id linkedRecordId = new List<Id>(linkedRecordIds).get(0);

            RequestValidator permissionValidator = createPermissionValidator(linkedRecordId);
            if (!permissionValidator.isValid()) {
                return new FileLinkResponseModel(permissionValidator.getErrorModel());
            }

            // Grant temporary access to the File, and store the new document Id
            destinationDocumentId = FileUtils.grantTemporaryAccessTo(contentDocumentId);
        }

        // Return response
        return new FileLinkResponseModel(
                fHCM2.UrlHelper.getFullFileUrl(destinationDocumentId));
    }

    /**
     * Creates and returns a RequestValidator which can determine whether the
     * current User is authorized to access Files linked to the given record Id.
     */
    private static RequestValidator createPermissionValidator(Id linkedRecordId) {
        RequestValidator validator = new RequestValidator();

        if (SObjectUtils.isOfType(linkedRecordId, FeedbackUtils.FEEDBACK_TYPE)) {
            validator.addRule(new IsConversationParticipantRule(
                        FeedbackUtils.getConversationId(linkedRecordId)));
        }

        return validator;
    }
}