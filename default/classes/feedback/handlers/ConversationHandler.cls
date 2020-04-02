/**
 * Object providing polymorphism for Conversations - i.e. behaviours that vary
 * depending on the type of the subject.
 */
public abstract class ConversationHandler {

    protected Id subjectId;
    protected Conversation__c record;

    public Id getSubject() {
        return subjectId;
    }

    public void setSubject(Id subjectId) {
        this.subjectId = subjectId;
    }

    public void setRecord(Conversation__c record) {
        this.record = record;
    }

    /**
     * Creates a SubjectModel from the stored subject.
     */
    public abstract SubjectModel createSubject();

    /**
     * Gets the TM ID associated with the stored subject.
     */
    public abstract Id getTmId();

    /**
     * Gets the appropriate Conversation_Subject__c field to link to our subject.
     */
    public abstract String getJunctionField();

    /**
     * Creates a URL to link to a specific comment in the conversation.
     */
    public String getLinkToComment(Id commentId) {
        return getLinkToComment(commentId, getTmId());
    }

    /**
     * Creates a URL to link to a specific comment in the conversation, without
     * incurring any queries.
     */
    public abstract String getLinkToComment(Id commentId, Id tmId);

    /**
     * Gets the full Conversation feed.
     */
    public virtual List<FeedItemModel> getFeed() {
        Set<Id> itemIds = new Map<Id, Comment__c>(record.Comments__r).keySet();
        return FeedbackUtils.getFeedback(itemIds);
    }
}
