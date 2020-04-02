/**
 * Controller for the Feedback module.
 */
public class FeedbackController {

    /**
     * Gets all Versions for a Feedback item.
     */
    public static FeedbackVersionsResponseModel getFeedbackVersions(String feedbackId) {

        // Validate request
        RequestValidator validator = new RequestValidator()
                .addRule(new ValidFeedbackIdRule(feedbackId))
                .addRule(new DoesFeedbackExistRule(feedbackId))
                .addRule(IsConversationParticipantRule.fromFeedbackId(feedbackId));
        if (!validator.isValid()) {
            return new FeedbackVersionsResponseModel(validator.getErrorModel());
        }

        // Get Versions
        return new FeedbackVersionsResponseModel(
                FeedbackUtils.getFeedbackVersionsFor(feedbackId));
    }

    /**
     * Saves a Feedback item.
     */
    public static FeedbackResponseModel insertFeedback(FeedItemModel feedback) {

        // Validate request
        RequestValidator validator = new RequestValidator()
                .addRule(new ValidConversationIdRule(feedback.conversationId))
                .addRule(new DoesConversationExistRule(feedback.conversationId))
                .addRule(new IsFeedbackNewRule(feedback.id))
                .addRule(new IsConversationParticipantRule(feedback.conversationId));
        if (!validator.isValid()) {
            return new FeedbackResponseModel(validator.getErrorModel());
        }

        // Perform insertion
        return new FeedbackResponseModel(FeedbackUtils.insertFeedback(feedback));
    }

    /**
     * Updates a Feedback item.
     */
    public static FeedbackResponseModel updateFeedback(FeedItemModel feedback) {

        // Verify request is valid
        RequestValidator validator = new RequestValidator()
                .addRule(new ValidConversationIdRule(feedback.conversationId))
                .addRule(new DoesConversationExistRule(feedback.conversationId))
                .addRule(new ValidFeedbackIdRule(feedback.Id))
                .addRule(new DoesFeedbackExistRule(feedback.id))
                .addRule(new HasEditFeedbackPermissionRule(feedback));
        if (!validator.isValid()) {
            return new FeedbackResponseModel(validator.getErrorModel());
        }

        // Perform update
        return new FeedbackResponseModel(FeedbackUtils.updateFeedback(feedback));
    }
}