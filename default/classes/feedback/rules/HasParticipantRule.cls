/**
 * Validation rule for determining whether a Conversation has Participants, i.e.
 * where the failure condition is that it has none.
 */
public class HasParticipantRule implements ValidationRule {

    private ConversationModel conversation;

    public HasParticipantRule(ConversationModel conversation) {
        this.conversation = conversation;
    }

    public Boolean isValid() {
        List<PersonModel> participants = conversation.participants;

        // Fail if there are no participants at all
        if (participants == null || participants.size() == 0) {
            return false;
        }

        // Fail if any of the participants are invalid
        for (PersonModel participant : participants) {
            if (participant.id == null) {
                return false;
            }
        }

        return true;
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(
                HttpUtils.STATUS_BAD_REQUEST, Label.Conversation_Has_No_Participants, '');
    }

}
