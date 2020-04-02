/**
 * Handler for TM Conversations.
 */
public class TeamMemberConversationHandler extends ConversationHandler {

    private static final String COMMENT_LINK_FORMAT =
            '/apex/Performance#/tm/{0}#{1}';

    // The subject's Objectives
    private List<Objective__c> objectives;

    public override SubjectModel createSubject() {
        return TeamMemberUtils.createPersonAsSubject(subjectId);
    }

    public override Id getTmId() {
        return subjectId;
    }

    public override String getJunctionField() {
        return ConversationSubjectUtils.TEAM_MEMBER_FIELD;
    }

    public override String getLinkToComment(Id commentId, Id tmId) {
        return fHCM2.UrlHelper.getFullUrl(
                String.format(
                        COMMENT_LINK_FORMAT,
                        new List<String>{tmId, commentId}
                )
        );
    }

    /**
     * Builds the full conversation feed, including events and comments from
     * other related conversations.
     */
    public override List<FeedItemModel> getFeed() {

        // Get feed items for comments in the TM conversation
        List<FeedItemModel> combinedFeed = FeedbackUtils.getFeedback(
            new Map<Id, Comment__c>(record.Comments__r).keySet());

        // Acquire objects needed for our generators
        objectives = ObjectiveRepository.getForTeamMember(subjectId);

        // Add feed items from related conversations
        for (FeedGenerator generator : getFeedGenerators()) {
            combinedFeed.addAll(generator.generate());
        }

        // Interleave items chronologically
        combinedFeed.sort();
        return combinedFeed;
    }

    /**
     * Provides the generators required to pull in comments from other conversation
     * feeds. New generators can be registered here.
     */
    private List<FeedGenerator> getFeedGenerators() {
        return new List<FeedGenerator>{
            new ObjectiveCommentFeedGenerator(objectives),
            new ObjectiveEventFeedGenerator(objectives)
        };
    }
}