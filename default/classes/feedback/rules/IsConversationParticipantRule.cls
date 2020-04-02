/**
 * Validation rule for determining whether the viewer of a conversation is a
 * a participant.
 */
public class IsConversationParticipantRule implements ValidationRule {

    private String conversationId;
    private String feedbackId;

    public IsConversationParticipantRule() {}

    public IsConversationParticipantRule(String conversationId) {
        this.conversationId = conversationId;
    }

    public static IsConversationParticipantRule fromFeedbackId(String feedbackId) {
        IsConversationParticipantRule rule = new IsConversationParticipantRule();
        rule.feedbackId = feedbackId;
        return rule;
    }

    public Boolean isValid() {

        // Find the Conversation, if we need to
        if (feedbackId != null) {
            try {
                conversationId = FeedbackUtils.getConversationId(feedbackId);
            } catch (Exception e) {
                return false;
            }
        }

        if (conversationId == null) {
            return false;
        } else {
            return ConversationUtils.isParticipant(
                    TeamMemberUtils.getTeamMemberId(UserInfo.getUserId()), conversationId);
        }
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(
                HttpUtils.STATUS_FORBIDDEN, Label.Conversation_Access_Denied, '');
    }
}
