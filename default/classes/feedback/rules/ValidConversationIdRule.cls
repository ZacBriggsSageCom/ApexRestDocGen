/**
 * Validation rule for determining whether a Conversation Id is valid.
 */
public class ValidConversationIdRule extends ValidIdRule {

    public ValidConversationIdRule(String conversationId) {
        super(conversationId, Label.Conversation_Id_Invalid);
    }

    public override Boolean isValid() {
        return super.isValid()
                && SObjectUtils.isOfType(recordId, ConversationUtils.CONVERSATION_TYPE);
    }
}