/**
 * Tests exercising the Conversation Repository
 */
@IsTest
public class ConversationRepositoryTest {

    @IsTest
    private static void testGetConversationById() {

        //GIVEN some conversations
        Conversation__c conversationA = new Conversation__c();
        Conversation__c conversationB = new Conversation__c();
        insert new List<Conversation__c>{conversationA, conversationB};

        //WHEN I retrieve a conversation by its ID
        Conversation__c retrievedConversation =
                ConversationRepository.getConversationById(conversationA.Id);

        //THEN I receive the original conversation
        System.assertEquals(conversationA.Id, retrievedConversation.Id);
        System.assertNotEquals(conversationB.Id, retrievedConversation.Id);

    }
}

