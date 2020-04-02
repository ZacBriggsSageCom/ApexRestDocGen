/**
 * Utilities for dealing with Conversation Subject junction objects.
 */
public class ConversationSubjectUtils {

    public static final String TEAM_MEMBER_FIELD = 'Team_Member__c';
    public static final String OBJECTIVE_FIELD = 'Objective__c';

    /**
     * Given a Conversation ID and a Conversation Handler, creates and returns a
     * junction object linking the conversation and subject.
     */
    public static Conversation_Subject__c createJunction(
            Id conversationId, ConversationHandler handler) {

        // Work out which type of subject this is
        String destinationField = handler.getJunctionField();

        // Create junction object
        Conversation_Subject__c junction = new Conversation_Subject__c(
            Conversation__c = conversationId
        );
        junction.put(destinationField, handler.getSubject());
        ConversationSubjectRepository.insertRecord(junction);
        return junction;
    }

    /**
     * Finds all Conversations linked to by the given junction objects.
     */
    public static List<Conversation__c> getLinkedConversations(
            List<Conversation_Subject__c> junctions) {
        Set<Id> conversationIds = new Set<Id>();
        for (Conversation_Subject__c junction : junctions) {
            conversationIds.add(junction.Conversation__c);
        }
        return ConversationRepository.getConversationsByIds(conversationIds);
    }
}