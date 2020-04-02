/**
 * Test class for the Comment REST controller.
 */
@isTest
public class CommentRestTest {

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
     * Buils URI string, given the Conversation ID and Feedback item ID URL params.
     */
    private static String buildURI(String conversationId, String feedbackId) {
        return '/' + CommentRest.CONVERSATION_PARAM + '/' +
                + conversationId
                + '/' + CommentRest.COMMENT_PARAM + '/' +
                + feedbackId;
    }

    /**
     * Get response, if expecting a FeedbackResponseModel.
     * (for per-item ops)
     */
    private static FeedbackResponseModel receiveResponse() {
        return (FeedbackResponseModel) RestTestUtils.getResponseBody(
                FeedbackResponseModel.class);
    }

    /**
     * Get response, if expecting a BaseResponseModel.
     */
    private static BaseResponseModel receiveDeprecatedMethodResponse() {
        return (BaseResponseModel) RestTestUtils.getResponseBody(
                BaseResponseModel.class);
    }

    //==========================================================================
    // Test Methods
    //==========================================================================

    @isTest
    private static void testGetConversationId() {

        // GIVEN I am viewing a Conversation
        setUpAsTm();
        createExistingFeedback();
        RestTestUtils.setupRestContext(
                'GET', buildURI(conversation.Id, feedback.id));

        // WHEN I get the Conversation ID, THEN it is correct
        System.assertEquals(
                conversation.id, CommentRest.getConversationId());
    }

    @isTest
    private static void testGetFeedbackItemId() {

        // GIVEN I am viewing a Conversation
        setUpAsTm();
        createExistingFeedback();
        RestTestUtils.setupRestContext(
                'GET', buildURI(conversation.Id, feedback.id));

        // WHEN I get the Feedback item ID, THEN it is correct
        System.assertEquals(
                feedback.Id, CommentRest.getFeedbackItemId());
    }

    @isTest
    private static void testInsertTeamMemberFeedback() {

        // GIVEN I am viewing a Conversation
        // AND I have a Feedback item to insert
        setUpAsTm();
        createConversation();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(subject.Id)
                .setConversation(conversation.id)
                .build();
        RestTestUtils.setupRestContext(
                'POST', buildURI(conversation.Id, feedback.id));

        // WHEN I try to insert it
        RestContext.request.requestBody =
                Blob.valueOf(JSON.serialize(feedback));
        CommentRest.insertTeamMemberFeedback();
        FeedbackResponseModel response = receiveResponse();

        // THEN the response code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the response does not contain an error
        System.assertEquals(null, response.error);

        // AND the response contains the saved Feedback
        System.assert(SObjectUtils.isValidId(response.item.id));
    }

    @isTest
    private static void testUpdateTeamMemberFeedback() {

        // GIVEN I am viewing a Conversation
        // AND I have a Feedback item
        setUpAsTm();
        createExistingFeedback();
        RestTestUtils.setupRestContext(
                'PUT', buildURI(conversation.Id, feedback.id));

        // AND I have some update to make to it
        feedback.content = 'potato';

        // WHEN I try to update it
        RestContext.request.requestBody =
                Blob.valueOf(JSON.serialize(feedback));
        CommentRest.updateTeamMemberFeedback();
        FeedbackResponseModel response = receiveResponse();

        // THEN the response code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the response does not contain an error
        System.assertEquals(null, response.error);

        // AND the response contains the new information
        System.assertEquals('potato', response.item.content);
    }

    //==========================================================================
    // Tests for Deprecated Operations
    //==========================================================================

    @isTest
    private static void testGetTeamMemberFeedback() {

        // GIVEN I am viewing a Conversation
        setUpAsTm();
        createExistingFeedback();
        RestTestUtils.setupRestContext('GET', buildURI(conversation.Id, ''));

        // WHEN I try to get its details
        CommentRest.getTeamMemberFeedback();
        BaseResponseModel response = receiveDeprecatedMethodResponse();

        // THEN the response code is FORBIDDEN
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());
    }

    @isTest
    private static void testDeleteTeamMemberFeedback() {

        // GIVEN I am viewing a Conversation
        // AND I have a Feedback item
        setUpAsTm();
        createExistingFeedback();
        RestTestUtils.setupRestContext(
                'DELETE', buildURI(conversation.Id, feedback.id));

        // WHEN I try to delete it
        CommentRest.deleteTeamMemberFeedback();
        BaseResponseModel response = receiveDeprecatedMethodResponse();

        // THEN the response code is FORBIDDEN
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());

        // AND the Feedback item has not been deleted
        System.assertNotEquals(null, FeedbackRepository.getFeedback(feedback.id));
    }

}