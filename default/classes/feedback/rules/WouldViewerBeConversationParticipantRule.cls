/**
 * Rule for determining whether the current viewer would be involved in a
 * conversation about some subject.
 */
public class WouldViewerBeConversationParticipantRule implements ValidationRule {

    private Id subjectId;

    public WouldViewerBeConversationParticipantRule(Id subjectId) {
        this.subjectId = subjectId;
    }

    public Boolean isValid() {

        // Identify the TM associated with the subject object
        String subjectType = SObjectUtils.getTypeNameOf(subjectId);
        Id tmId;
        try {
            tmId = ConversationHandlerRegistry.getHandlerForSubject(subjectId).getTmId();
        } catch (NullPointerException e) {
            return false;
        }

        // Determine whether we have the appropriate relationship with the TM
        Viewport viewport;
        try {
            viewport = new Viewport(tmId);
        } catch (Exception e) {
            return false;
        }
        return viewport.isTeamMember() || viewport.isManager();
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(
                HttpUtils.STATUS_FORBIDDEN, Label.Conversation_Creation_Denied, '');
    }
}
