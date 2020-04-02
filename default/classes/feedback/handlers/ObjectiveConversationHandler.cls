/**
 * Handler for Conversations about Objectives.
 */
public class ObjectiveConversationHandler extends ConversationHandler {

    private static final String COMMENT_LINK_FORMAT =
            '/apex/Performance#/tm/{0}/objectives/{1}#{2}';

    public override SubjectModel createSubject() {
        return ObjectiveUtils.createObjectiveAsSubject(subjectId);
    }

    public override Id getTmId() {
        return ObjectiveRepository.get(subjectId).Team_Member__c;
    }

    public override String getJunctionField() {
        return ConversationSubjectUtils.OBJECTIVE_FIELD;
    }

    public override String getLinkToComment(Id commentId, Id tmId) {
        return fHCM2.UrlHelper.getFullUrl(
                String.format(
                        COMMENT_LINK_FORMAT,
                        new List<String>{tmId, subjectId, commentId}
                )
        );
    }
}