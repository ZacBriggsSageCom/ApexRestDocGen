/**
 * Helper class for building Conversation__c records from ConversationModels.
 */
public class ConversationRecordBuilder {

    /**
     * Convert a single ConversationModel into a Conversation__c record.
     */
    public static Conversation__c build(ConversationModel model) {
        return new Conversation__c(Name = model.name);
    }
}
