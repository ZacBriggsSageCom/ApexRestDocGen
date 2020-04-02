@isTest
public class ConversationParticipantRepositoryTest {

    private static Conversation__c conversation;

    private static void setUp() {
        conversation = new Conversation__c();
        insert conversation;
    }

    @isTest
    private static void testGetParticipantsByConversationID() {
        //GIVEN some saved Conversation Participant
        setUp();
        fHCM2__Team_Member__c participant1 =
                new TeamMemberTestUtils.TeamMemberBuilder().build();

        fHCM2__Team_Member__c participant2 =
                new TeamMemberTestUtils.TeamMemberBuilder().build();

        Conversation_Participant__c firstConversationParticipant = new Conversation_Participant__c(
                Conversation__c = conversation.Id,
                Team_Member__c = participant1.Id
        );
        Conversation_Participant__c secondConversationParticipant = new Conversation_Participant__c(
                Conversation__c = conversation.Id,
                Team_Member__c = participant2.Id
        );
        insert new List<Conversation_Participant__c>{
                firstConversationParticipant,
                secondConversationParticipant
        };

        // WHEN I retrieve their properties
        List<Conversation_Participant__c> retrievedConversationParticipants =
                ConversationParticipantRepository.getParticipantsByConversationId(conversation.id);

        // THEN I get the same information back
        System.assertEquals(participant1.Id, retrievedConversationParticipants[0].Team_Member__c);
        System.assertEquals(conversation.Id, retrievedConversationParticipants[0].Conversation__c);
        System.assertEquals(participant2.Id, retrievedConversationParticipants[1].Team_Member__c);
        System.assertEquals(conversation.Id, retrievedConversationParticipants[1].Conversation__c);

    }
}