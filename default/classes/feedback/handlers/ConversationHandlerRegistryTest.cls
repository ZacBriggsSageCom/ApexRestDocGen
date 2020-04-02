@isTest
public class ConversationHandlerRegistryTest {

    private static ObjectiveModel obj;
    private static ConversationModel conversation;
    private static Conversation__c conversationRecord;
    private static fHCM2__Team_Member__c tm;

    private static void setUp() {
        fHCM2__Policy__c pol = new fHCM2__Policy__c();
        insert pol;

        tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setUser(UserInfo.getUserId())
                .build();

        obj = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTitle('Do something')
                .setTeamMember(tm.Id)
                .save()
                .build();

        conversationRecord = new Conversation__c();
        insert conversationRecord;
    }

    private static void createConversation() {
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .addParticipant(tm)
                .setSubject(obj.id)
                .save()
                .build();
    }

    @isTest
    private static void testIsAcceptableSubjectTypeWhenIsNot() {

        // GIVEN some object which is not suitable as a conversation subject
        setUp();

        // WHEN I check whether it is acceptable, THEN I find it is not
        System.assert(!ConversationHandlerRegistry.isAcceptableSubjectType(
                conversationRecord.Id));
    }

    @isTest
    private static void testIsAcceptableSubjectTypeWhenIs() {

        // GIVEN an object which is suitable as a conversation subject
        setUp();

        // WHEN I check whether it is acceptable, THEN I find it is
        System.assert(ConversationHandlerRegistry.isAcceptableSubjectType(obj.id));
    }

    @isTest
    private static void testGetHandlerForSubjectId() {

        // GIVEN the ID of a valid subject
        setUp();

        // WHEN I get a suitable conversation handler
        ConversationHandler handler =
                ConversationHandlerRegistry.getHandlerForSubject(obj.id);

        // THEN it is built properly
        System.assertNotEquals(null, handler);

        // AND it is of the correct type
        System.assert(handler instanceof ObjectiveConversationHandler);
    }

    @isTest
    private static void testGetHandlerForSubjectIdWhenInvalidType() {

        // GIVEN an ID of an object which cannot be a conversation subject
        setUp();

        // WHEN I attmept to get a suitable conversation handler, THEN I get nothing
        System.assertEquals(
                null,
                ConversationHandlerRegistry.getHandlerForSubject(conversationRecord.Id)
        );
    }

    @isTest
    private static void testGetHandlerForConversationId() {

        // GIVEN a Conversation
        setUp();
        createConversation();

        // WHEN I get a handler for it using its ID
        ConversationHandler handler =
                ConversationHandlerRegistry.getHandlerForConversationId(conversation.id);

        // THEN it is populated
        System.assertNotEquals(null, handler);

        // AND it is of the correct type
        System.assert(handler instanceof ObjectiveConversationHandler);
    }
}