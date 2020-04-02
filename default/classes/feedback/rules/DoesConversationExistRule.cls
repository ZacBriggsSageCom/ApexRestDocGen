/**
 * Validation rule for determining whether a Conversation record exists, i.e. where
 * the failure condition is that the Conversation does not exist.
 */
public class DoesConversationExistRule extends DoesRecordExistRule {

    public DoesConversationExistRule(String conversationId) {
        super(conversationId, Label.Conversation_Does_Not_Exist);
    }
}
