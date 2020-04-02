/**
 * Validation rule for determining whether a Conversation record is new, i.e. where
 * the failure condition is that the Conversation already exists.
 */
public class IsConversationNewRule extends IsRecordNewRule {

    public IsConversationNewRule(String conversationId) {
        super(conversationId, Label.Conversation_Already_Exists);
    }
}
