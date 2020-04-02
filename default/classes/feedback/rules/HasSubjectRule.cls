/**
 * Validation rule for determining whether a Conversation has a Subject, i.e.
 * where the failure condition is that it does not.
 */
public class HasSubjectRule implements ValidationRule {

    private ConversationModel conversation;

    public HasSubjectRule(ConversationModel conversation) {
        this.conversation = conversation;
    }

    /**
     * Fail if the subject is missing, or if it has no ID.
     */
    public Boolean isValid() {
        SubjectModel subject = conversation.subject;
        return subject != null && subject.id != null;
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(
                HttpUtils.STATUS_BAD_REQUEST, Label.Conversation_Has_No_Subject, '');
    }
}
