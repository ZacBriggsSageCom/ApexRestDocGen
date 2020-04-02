@isTest
public class ConversationSubjectUtilsTest {

    @isTest
    private static void testCreateJunction() {

        // GIVEN some subject
        fHCM2__Policy__c pol = new fHCM2__Policy__c();
        insert pol;
        fHCM2__Team_Member__c tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Dan Quill')
                .setUser(UserInfo.getUserId())
                .setPolicy(pol.Id)
                .build();
        ObjectiveModel obj = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTitle('Become ThinMatrix')
                .setTeamMember(tm.Id)
                .save()
                .build();

        // AND a conversation
        Conversation__c conv = new Conversation__c();
        insert conv;

        // AND a handler
        ConversationHandler handler =
                ConversationHandlerRegistry.getHandlerForSubject(obj.id);

        // WHEN I create the junction object to link conversation and subject
        ConversationSubjectUtils.createJunction(conv.Id, handler);

        // THEN it has been saved
        System.assertEquals(1, [SELECT Id FROM Conversation_Subject__c].size());
    }

    @isTest
    private static void testGetLinkedConversations() {

        // GIVEN a conversation
        Conversation__c conv = new Conversation__c();
        insert conv;

        // AND a list of one junction object linking to it
        List<Conversation_Subject__c> junctions = new List<Conversation_Subject__c>{
            new Conversation_Subject__c(Conversation__c = conv.Id)
        };
        insert junctions;

        // WHEN I get all conversations linked to by the junction
        List<Conversation__c> linkedConversations =
                ConversationSubjectUtils.getLinkedConversations(junctions);

        // THEN I get the right one
        System.assertEquals(1, linkedConversations.size());
        System.assertEquals(conv.Id, linkedConversations[0].Id);
    }
}