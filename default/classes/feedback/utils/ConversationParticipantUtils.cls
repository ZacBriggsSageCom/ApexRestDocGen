/**
 * Utilities for dealing with Conversation Participant junction objects.
 */
public class ConversationParticipantUtils {

    /**
     * For a Conversation ID and a some Team Member IDs, creates Participant
     * junctions linking each.
     */
    public static List<Conversation_Participant__c> createJunctions(
            Id conversationId, Set<Id> tmIds) {

        List<Conversation_Participant__c> junctions =
                new List<Conversation_Participant__c>();
        for (Id tmId : tmIds) {
            if (tmId != null) {
                junctions.add(new Conversation_Participant__c(
                    Conversation__c = conversationId,
                    Team_Member__c = tmId
                ));
            }
        }

        ConversationParticipantRepository.insertRecords(junctions);
        return junctions;
    }
}
