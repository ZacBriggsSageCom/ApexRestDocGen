/**
 * Controller for Conversation operations.
 */
public class ConversationController {

    /**
     * Gets a Conversation and its details by ID.
     */
    public static ConversationResponseModel getConversation(String conversationId) {

        // Validate request
        RequestValidator validator = new RequestValidator()
                .addRule(new ValidConversationIdRule(conversationId))
                .addRule(new DoesConversationExistRule(conversationId))
                .addRule(new IsConversationParticipantRule(conversationId));
        if (!validator.isValid()) {
            return new ConversationResponseModel(validator.getErrorModel());
        }

        // Get Conversation
        return new ConversationResponseModel(
                ConversationUtils.getConversation(conversationId));
    }

    /**
     * Gets a Conversation and its details by subject ID. The Conversation will
     * be created if it does not exist.
     */
    public static ConversationResponseModel getConversationBySubject(String subjectId) {

        // Validate request
        RequestValidator validator = new RequestValidator()
                .addRule(new ValidIdRule(subjectId, Label.Subject_ID_Invalid))
                .addRule(new DoesRecordExistRule(subjectId, Label.Subject_Does_Not_Exist));
        if (!validator.isValid()) {
            return new ConversationResponseModel(validator.getErrorModel());
        }

        // Find conversation, if we can; otherwise create one
        Id conversationId = ConversationUtils.findBySubject(subjectId);
        return conversationId == null
                ? createConversationFromSubject(subjectId)
                : getExistingConversation(conversationId);
    }

    /**
     * Builds a Conversation from a Subject ID.
     */
    private static ConversationResponseModel createConversationFromSubject(Id subjectId) {
        RequestValidator validator = new RequestValidator()
                .addRule(new IsValidSubjectForConversationRule(subjectId))
                .addRule(new WouldViewerBeConversationParticipantRule(subjectId));
        if (!validator.isValid()) {
            return new ConversationResponseModel(validator.getErrorModel());
        }
        return new ConversationResponseModel(
                ConversationUtils.createConversationAbout(subjectId));
    }

    /**
     * Gets a Conversation by ID, on the assumption that it exists.
     */
    private static ConversationResponseModel getExistingConversation(Id conversationId) {
        RequestValidator validator = new RequestValidator()
                .addRule(new IsConversationParticipantRule(conversationId));
        if (!validator.isValid()) {
            return new ConversationResponseModel(validator.getErrorModel());
        }
        return new ConversationResponseModel(
            ConversationUtils.getConversation(conversationId));
    }

    /**
     * Saves a new Conversation and returns it.
     */
    public static ConversationResponseModel insertConversation(
            ConversationModel conversation) {

        // Validate request
        RequestValidator validator = new RequestValidator()
                .addRule(new IsConversationNewRule(conversation.id))
                .addRule(new HasSubjectRule(conversation))
                .addRule(new HasParticipantRule(conversation));
        if (!validator.isValid()) {
            return new ConversationResponseModel(validator.getErrorModel());
        }

        // Perform insertion
        return new ConversationResponseModel(
                ConversationUtils.insertConversation(conversation));
    }

}