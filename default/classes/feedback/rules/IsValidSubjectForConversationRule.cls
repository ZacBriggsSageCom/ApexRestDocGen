/**
 * Rule for determining whether a subject object is one of the permissible types
 * for a conversation to be about.
 */
public class IsValidSubjectForConversationRule implements ValidationRule {

    private Id subjectId;

    public IsValidSubjectForConversationRule(Id subjectId) {
        this.subjectId = subjectId;
    }

    public Boolean isValid() {
        return ConversationHandlerRegistry.isAcceptableSubjectType(subjectId);
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(
                HttpUtils.STATUS_BAD_REQUEST, Label.Invalid_Subject_Type, '');
    }
}