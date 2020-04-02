public class FeedbackRecordBuilder {

    /**
     * Converts a FeedItemModel into a Comment record, using the provided
     * current version number.
     */
    public static Comment__c build(FeedItemModel model, Integer versionNumber) {
        return new Comment__c(
            Id = model.id,
            Author__c = model.comment.author.id,
            Conversation__c = model.conversationId,
            Current_Version__c = versionNumber
        );
    }
}