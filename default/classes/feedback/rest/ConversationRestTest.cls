/**
 * Test class for the Conversation REST controller.
 */
@isTest
public class ConversationRestTest {

    private static fHCM2__Team_Member__c subject;
    private static ConversationModel conversation;
    private static FeedItemModel feedback;

    /**
     * Set up with the subject being the viewer.
     */
    private static void setUpAsTm() {
        fHCM2__Policy__c pol =
                new fHCM2__Policy__c(Allow_Edit_Feedback__c = true);
        insert pol;
        subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setPolicy(pol.Id)
                .build();
    }

    /**
     * Create and save some default Feedback item.
     */
    private static void createExistingFeedback() {
        createConversation();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(subject.Id)
                .setConversation(conversation.id)
                .save()
                .build();
    }

    /**
     * Create and save a Conversation between the subject and the viewer, and
     * about the subject.
     */
    private static void createConversation() {
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .save()
                .build();
    }

    //==========================================================================
    // Utility Methods
    //==========================================================================

    /**
     * Buils URI string, given the Conversation ID URL param.
     */
    private static String buildURI(String conversationId) {
        return '/' + ConversationRest.CONVERSATION_PARAM + '/' +
                + conversationId;
    }

    /**
     * Gets HTTP response, if expecting a ConversationResponseModel.
     */
    private static ConversationResponseModel receiveResponse() {
        return (ConversationResponseModel) RestTestUtils.getResponseBody(
                ConversationResponseModel.class);
    }

    //==========================================================================
    // Test Methods
    //==========================================================================

    @isTest
    private static void testGetConversationId() {

        // GIVEN I am viewing a Conversation
        setUpAsTm();
        createExistingFeedback();
        RestTestUtils.setupRestContext('GET', buildURI(conversation.Id));

        // WHEN I get the Conversation ID, THEN it is correct
        System.assertEquals(
                conversation.id, ConversationRest.getConversationId());
    }

    @isTest
    private static void testGetConversation() {

        // GIVEN a Conversation
        setUpAsTm();
        createExistingFeedback();
        RestTestUtils.setupRestContext('GET', buildURI(conversation.Id));

        // WHEN I get its details
        ConversationRest.getConversation();
        ConversationResponseModel response = receiveResponse();

        // THEN the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the response does not contain an error
        System.assertEquals(null, response.error);

        // AND the response contains the Conversation
        System.assertNotEquals(null, response.conversation);
    }

    @isTest
    private static void testInsertConversation() {

        // GIVEN a Conversation I want to save
        setUpAsTm();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .build();
        RestTestUtils.setupRestContext('POST', buildURI(conversation.Id));
        RestTestUtils.setRequestBody(conversation);

        // WHEN I save it
        ConversationRest.insertConversation();
        ConversationResponseModel response = receiveResponse();

        // THEN the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the response does not contain an error
        System.assertEquals(null, response.error);

        // AND the response contains the Conversation
        System.assertNotEquals(null, response.conversation);

        // AND the Conversation has been saved
        System.assertNotEquals(null, response.conversation.id);
    }
}